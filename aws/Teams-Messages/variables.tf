variable "setup" {
  type = map
  default = {
    name = "cloudwatch"
    environment = "prod"
    creator = "terraform"
    account = "123456789012"

    enable_ec2 = false
    enable_alb = true
    enable_rds = true
    enable_reddis = true
    enable_pagepull = true
  }
}


variable "network_settings" {
  type = map
  default = {
    region = "eu-west-1"
    domain_name = "platform.net"
  }
}

variable "albs" {
  type = map
  default = {
    alb01 = {
      enabled = "true"
      alb_name = "production-lb"
      alb_fullname = "app/661c7"
      alb_target = "targetgroup/platform/02a9"
      threshold_high = "2"
      threshold_urgent = "1"
    }
  }
}

variable "servers" {
  type = map
  default = {
    server01 = {
      name = "dview-web-01"
      enabled = "true"
      id = "i-038978" 
      cpu_threshold = 80
      net_threshold = 200000000
    }
  }
}

variable "databases" {
  type = map
  default = {
    db01 = {
      name = "platform-mysql-01"
      enabled = "true"
      cpu_threshold = 60
      connection_threshold = 20
      mem_threshold = 300000000
      storage_threshold = 0
      short_name = "platform-mysql-01"
    }
  }
}

variable "logging" {
  type = map
  default = {
    failure_feedback_role_arn = "arn:aws:iam::123456789012:role/SNSFailureFeedback"
    success_feedback_role_arn = "arn:aws:iam::123456789012:role/SNSSuccessFeedback"
    success_feedback_sample_rate = 100
  }
}

variable "alerts" {
  type = map
  default = {
    low = {
      name = "low"
      teams_enabled = true
      teams_url = "https://companyname.webhook.office.com/webhookb2/459f65ebf@d56bb89aa/IncomingWebhook/f48f89b5317447656097/8771a56c1219fe5ac"
      email_enabled = false
      email_addr = "admin_email@company.com"
      sms_enabled = false
      sms_addr = "+353865555555"
    }
  }
}










