using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ProducerConsumerApi.Models.Dtos
{
    [ProtoContract]
    public class CommandDataRequestDto : RequestBase
    {
        [ProtoMember(1)]
        public string ServiceGuid { get; set; }
        [ProtoMember(2)]
        public string SenderGuid { get; set; }
    }
}
