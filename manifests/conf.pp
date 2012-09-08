#
# class conf - default settings for bind
#
class conf {
  $setup = {
    'template-named-conf'  => "bind/named.conf.erb",
    'port'                 => 53
  }
  $conf = {
    'options' => {
      'listen-on port 53'      => {'127.0.0.1' => ''},
      'listen-on-v6 port 53'   => {'::1' => ''},
      'directory'              =>  "/var/named",
      'dump-file'              =>  "/var/named/data/cache_dump.db",
      'statistics-file'        =>  "/var/named/data/named_stats.txt",
      'memstatistics-file'     =>  "/var/named/data/named_mem_stats.txt",
      'directory'              =>  "/var/named",
      'allow-query'            =>  {'any' => ''},
      'recursion'              => 'yes',
      'dnssec-enable'          => 'yes',
      'dnssec-validation'      => 'yes',
      'dnssec-lookaside'       => 'auto',
      'bindkeys-file'          => '/etc/named.iscdlv.key',
      'managed-keys-directory' => '/var/named/dynamic'
    },
    'Include' => [
      '/etc/named.rfc1912.zones',
      '/etc/named.custom.zones',
      '/etc/named.root.key'
    ] 
  }
  $confRecordsSetups = {
    'default' => [{}],
    'gmail' => [{}],
  }
}
