{
  "set_fqdn":"app-server",
  "run_list":[
    "recipe[fully-chef::default]",
    "recipe[fully-chef::nginx]"
  ],

  "fully-chef": {
    "directory": "/fully/data"
  },

  "nginx": {
    "ip_address": "<EXTERNAL_IP>"
  }
}