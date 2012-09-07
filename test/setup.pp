bind::setup { 'bind-setup ':
  ensure    = installed,  # Optional
  boot      = true, # Optional
  status    = 'running', # Optional
  bindSetup = {}, # Optional
  bindConf  = {}, # Optional
  rdncGen   = true, # Optional
  firewall  = false, # Optional
  port      = 53 # Optional
}

bind::zone::new {'bind-zone-sandbox.dev':
  domain = 'sandbox.dev'
  records = []
  TTL          = 86400, # Optional
  serial       = 100, # Optional
  refresh      = 1H, # Optional
  retry        = 1M, # Optional
  expiry       = 1W, # Optional
  minimum      = 1D, # Optional  
}

bind::reverse::new {'bind-reverse-192.168.0':
  ip           = '192.168.0',
  IN           = 'ns1.sandbox.dev root.sandbox.dev'
  defaultIpEnd = '1',
  records      = [
    {'type': 'NS', 'value': 'ns1.sandbox.dev'},  
    {'type': 'PTR', 'value': 'sandbox.dev'},
    {'type': 'PTR', 'value': 'subdomain.sandbox.dev'},
    {'type': 'PTR', 'value': 'sandbox.dev', 'ipEnd': 2}    
  ], # NS, CNANE, or PTR
  TTL          = 86400, # Optional
  serial       = 100, # Optional
  refresh      = 1H, # Optional
  retry        = 1M, # Optional
  expiry       = 1W, # Optional
  minimum      = 1D, # Optional
}