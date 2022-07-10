using ProducerConsumerApi.Models.Dtos;
using ProtoBuf;
using System;

namespace ProducerConsumerApi.Models
{
    [ProtoContract,
       ProtoInclude(1, typeof(CommandDataRequestDto))]
    public class RequestBase
    {
        [ProtoMember(1)]
        public Type Command { get; set; }
    }
}
