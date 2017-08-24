# bitbucket-boshrelease
This release is designed to use postgres and haproxy

## Releases for ssl and database
* http://bosh.io/d/github.com/cloudfoundry/postgres-release?v=18
* http://bosh.io/d/github.com/cloudfoundry-community/haproxy-boshrelease?v=8.3.0

## Release usage
* This release is in dev, so to use it follow this step
```shell
git clone https://github.com/camillemahaut/bitbucket-boshrelease.git
cd bitbucket-boshrelease
./scripts/build-release.sh $version (ex:1.0)
```
depends on your bosh cli version
```shell
bosh -e $env upload-release
```
* then deploy with your manifest

## bitbucket property example
```yaml manifest
 bitbucket:
  port: 7990
  java_version: jdk1.8.0_131
  hazelcast_group_name: your-bitbucket-cluster
  hazelcast_group_password: your-bitbucket-cluster
  plugin_search_elasticsearch_baseurl: http://localhost:7999/
  server_session_cookie_name: JSESSIONID
  server_proxy_name: your proxy ip
  jdbc_url: jdbc:postgresql://postgresqlIPorName:5432/bitbucket
  postgres_port: 5432
  jdbc_user: admin
  jdbc_password: password
  setup_license: "licence key"
  setup_displayName: displayName 
  setup_baseUrl: https://git.your.domain.com
  setup_sysadmin_username: username
  setup_sysadmin_password: password
  setup_sysadmin_displayName: John Doe
  setup_sysadmin_emailAddress: webadmin@bitbucket.com
```
## postgresSQL property example
```yaml manifest
 databases:
  databases:
  - citext: true
    name: bitbucket
    tag: bitbucket
  port: 5432
  roles:
  - name: user
    password: password
    tag: admin
    permissions:
    - CONNECTION LIMIT 10
```

## haproxy property example
```yaml manifest
 ha_proxy:
  ssl_pem: |
    -----BEGIN CERTIFICATE-----
    MIIDlzCCAyour certificate
    -----END CERTIFICATE-----
    -----BEGIN PRIVATE KEY-----
    MIIEvAI private key  y+yAzqg5QioHxCok3+KAog==
    -----END PRIVATE KEY-----
 backend_servers: 
  - 127.0.0.1
  backend_port: 7990
  https_redirect_all: true
  tcp:
  - name: sshd        # required - name of backend
    port: 2222       # required - port haproxy should listen on
    backend_servers: # required - list of backend IPs to connect to
    - 127.0.0.1
    backend_port: 7999 # optional - sets backend port - otherwise defaults to `port`

```



