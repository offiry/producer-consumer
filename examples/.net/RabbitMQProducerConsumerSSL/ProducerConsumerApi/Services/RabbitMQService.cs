using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json;
using ProducerConsumerApi.Contracts;
using ProducerConsumerApi.Models;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Authentication;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace ProducerConsumerApi.Services
{
    public class RabbitMQService : IRabbitMQService
    {
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private IConnection _connection;
        private IModel _channel;
        private readonly string _exchange = "CqrsServiceExchange";
        private readonly string _exchangeType = ExchangeType.Fanout;
        private QueueDeclareOk _queue;
        private EventingBasicConsumer _consumer;

        public RabbitMQService(IConfiguration configuration, IWebHostEnvironment webHostEnvironment)
        {
            _configuration = configuration;
            _webHostEnvironment = webHostEnvironment;

            OpenConnection().Wait();

            Console.WriteLine("--> Cqrs Service Connected to RabbitMQ Message Bus.");
        }

        public async Task PublishMessage<TCommandRequest>(TCommandRequest commandRequest) where TCommandRequest : RequestBase
        {
            if (_channel.IsOpen)
            {
                await Task.Factory.StartNew(() =>
                {
                    var message = JsonConvert.SerializeObject(commandRequest);
                    var body = Encoding.UTF8.GetBytes(message);
                    _channel.BasicPublish(exchange: _exchange, string.Empty, basicProperties: null, body: body);

                    Console.WriteLine($"--> Producer Sent Message: {message}");
                });
            }
            else
                throw new Exception("--> Cannot publish message, channel closed!");
        }

        private void HandleRabbitConnectionShutdown(object o, ShutdownEventArgs args)
        {
            if (_channel != null)
            {
                _channel.Close();
                _channel = null;
            }

            if (_connection != null)
            {
                try
                {
                    if (_connection.IsOpen)
                        _connection.Close();
                }
                catch (IOException io)
                {
                    Console.WriteLine($"--> Command Service IOException: {io.Message}.");
                }

                _connection.ConnectionShutdown -= (o, args) => HandleRabbitConnectionShutdown(o, args);
                _connection = null;
            }
        }

        private Task OpenConnection()
        {
            if (_connection is null || !_connection.IsOpen)
            {
                ConnectionFactory cf = new ConnectionFactory();
                String root = null;
                DirectoryInfo projectFolder = null;

                Console.WriteLine($"--> Command Service HostName1 Address: {_configuration.GetSection("HostName1").Get<string>()}.");
                Console.WriteLine($"--> Command Service RabbitMQ Address: {_configuration.GetSection("ClientCertificate").Get<string>()}.");


                cf.HostName = _configuration.GetSection("HostName1").Get<string>();
                cf.Ssl.Enabled = true;
                cf.Ssl.ServerName = "testca1";
                cf.Ssl.CertPath = _configuration.GetSection("ClientCertificate").Get<string>();
                cf.Ssl.CertPassphrase = "MySecretPassword";
                cf.Ssl.Version = SslProtocols.Tls12;
                cf.UserName = "admin";
                cf.Password = "admin";

                if (_webHostEnvironment.EnvironmentName == Environments.Development)
                {
                    root = AppContext.BaseDirectory.Substring(0, AppContext.BaseDirectory.IndexOf("bin"));
                    projectFolder = Directory.GetParent(root).Parent.Parent.Parent.Parent;
                    cf.Ssl.CertPath = projectFolder + @"\client\client_certificate.p12";
                }

                _connection = cf.CreateConnection();
                _connection.ConnectionShutdown += (o, args) => HandleRabbitConnectionShutdown(o, args);

                _channel = _connection.CreateModel();
                _channel.ExchangeDeclare(exchange: _exchange, type: _exchangeType);
            }

            return Task.CompletedTask;
        }

        public Task StartConsumer()
        {
            if (!(_channel is null) && _channel.IsOpen && _queue.ConsumerCount == 0)
            {
                _consumer = new EventingBasicConsumer(_channel);

                _consumer.Received += HandleConsumerMessage;
                _consumer.Shutdown += HandleConsumerShutdown;

                _channel.BasicConsume(queue: _queue, autoAck: false, consumer: _consumer);
            }

            return Task.CompletedTask;
        }

        private void HandleConsumerShutdown(object sender, ShutdownEventArgs e)
        {
            if (!(_consumer is null))
            {
                _consumer.Received -= HandleConsumerMessage;
                _consumer.Shutdown -= HandleConsumerShutdown;
            }

            _consumer = null;
        }

        private void HandleConsumerMessage(object o, BasicDeliverEventArgs e)
        {
            var requestBase = JsonConvert.DeserializeObject<RequestBase>(Encoding.UTF8.GetString(e.Body.ToArray()));
            var baseMessage = JsonConvert.DeserializeObject(Encoding.UTF8.GetString(e.Body.ToArray()), requestBase.Command);
            var serObject = JsonConvert.SerializeObject(baseMessage);

            Console.WriteLine($"--> Consumer Received Message: {serObject}");
        }
    }
}
