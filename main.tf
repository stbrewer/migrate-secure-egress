data "aws_vpc" "selected" {
  filter {
  name   = "tag:Name"
  values = ["AWS-Egress-TF-Demo-VPC"]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["AWS-Egress-TF-Demo-VPC-Public-1-us-east-1a"]
  }
}

resource "aviatrix_spoke_gateway" "AWS-Egress-TF-Demo" {
  cloud_type        = 1
  account_name      = "AWS_Environment"
  gw_name           = "AWS-Egress-TF-Demo-GW"
  vpc_id            = data.aws_vpc.selected.id
  vpc_reg           = "us-east-1"
  gw_size           = "t3.small"
  subnet            = data.aws_subnet.selected.cidr_block
  single_ip_snat    = false
}

resource "aviatrix_smart_group" "AWS-Egress-TF-Demo-SG" {
  name = "AWS-Egress-TF-Demo-SG"
  selector {
    match_expressions {
      type         = "vm"
      account_name = "AWS_Environment"
      region       = "us-east-1"
      tags         = {
        Demo = "Egress"
      }
    }
  }
}

resource "aviatrix_web_group" "AWS-Egress-TF-Demo-WG" {
  name = "AWS-Egress-TF-Demo-WG"
  selector {
    match_expressions {
      snifilter = "*.github.com"
    }
  }
}

resource "aviatrix_distributed_firewalling_config" "Turn-On-FW" {
  enable_distributed_firewalling = true
}

resource "aviatrix_distributed_firewalling_policy_list" "test" {
  policies {
    name             = "AWS-Egress-TF-Demo-Firewall-Policy"
    action           = "PERMIT"
    priority         = 1
    protocol         = "TCP"
    port_ranges {
      lo = 80
    }
    web_groups       = [aviatrix_web_group.AWS-Egress-TF-Demo-WG.uuid]
    logging          = true
    watch            = false
    src_smart_groups = [
      aviatrix_smart_group.AWS-Egress-TF-Demo-SG.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001"
    ]
  }
}