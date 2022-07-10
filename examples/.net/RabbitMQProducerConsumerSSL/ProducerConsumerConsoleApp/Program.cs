using RabbitMQ.Client;
using System;
using System.IO;
using System.Net.Security;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;

namespace ProducerConsumerConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            ConnectionFactory cf = new ConnectionFactory();

            var root = AppContext.BaseDirectory.Substring(0, AppContext.BaseDirectory.IndexOf("bin"));
            var projectFolder = Directory.GetParent(root).Parent.Parent.Parent.Parent;

            cf.HostName = "127.0.0.1";
            cf.Ssl.Enabled = true;
            cf.Ssl.CertificateValidationCallback = MySslCertificateValidationCallback;
            //cf.Ssl.ServerName = System.Net.Dns.GetHostName();
            cf.Ssl.ServerName = "testca1";
            cf.Ssl.CertPath = projectFolder + @"\client\client_certificate.p12";
            cf.Ssl.CertPassphrase = "MySecretPassword";
            cf.Ssl.Version = SslProtocols.Tls12;
            cf.UserName = "admin";
            cf.Password = "admin";

            using (IConnection conn = cf.CreateConnection())
            {
                using (IModel ch = conn.CreateModel())
                {
                    Console.WriteLine("Successfully connected and opened a channel");
                    ch.QueueDeclare("rabbitmq-dotnet-test", false, false, false, null);
                    Console.WriteLine("Successfully declared a queue");
                    ch.QueueDelete("rabbitmq-dotnet-test");
                    Console.WriteLine("Successfully deleted the queue");
                }
            }

            Console.WriteLine();
        }

        private static bool MySslCertificateValidationCallback(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            // If there are no errors, then everything went smoothly.
            if (sslPolicyErrors == SslPolicyErrors.None)
                return true;

            return false;
        }
    }
}
