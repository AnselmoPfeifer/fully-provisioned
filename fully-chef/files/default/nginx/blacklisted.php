<?php
    function getRealIpAddr()
    {
        printf("\ngetRealIpAddr\n");
        if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
        {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        }
        elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
        {
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        }
        else
        {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }

    function reloadNginx()
    {
        printf( "\nreloadNginx\n");
        $command = "sudo service nginx reload";
        $escaped_command = escapeshellcmd($command);
        return system($escaped_command);
    }

    function updateBlackList($ip)
    {
        printf("\nupdateBlackList\n");
        $file = fopen('blockips.txt', 'w') or die('Unable to open file!');
        $content = "#deny 127.0.0.1;\n";
        fwrite($file, $content);
        $content = "deny ${ip};\n";
        fwrite($file, $content);
        fclose($file);

    }

    function setHttpsStatusCode()
    {
        printf( "\nsetHttpsStatusCode\n");
        updateBlackList(getRealIpAddr());
        reloadNginx();
        return http_response_code(444);
    }

setHttpsStatusCode();

