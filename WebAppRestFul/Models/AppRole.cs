﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebAppRestFul.Models
{
    public class AppRole
    {
        public Guid? Id { get; set; }

        public string Name { get; set; }

        public string NormalizedName { get; set; }
    }
}