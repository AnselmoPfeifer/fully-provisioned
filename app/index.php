<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>App - Fully Provisioned</title>
    <link href='https://fonts.googleapis.com/css?family=Lato:400' rel='stylesheet' type='text/css'>

    <style>
        * {
            box-sizing: border-box;
        }
        body {
            background: #686868;
            font-family: 'Lato', sans-serif;
        }
        .wrapper {
            width:100%;
            height: auto;
            margin: auto;
            text-align: center;
            padding: 60px 15px;
        }
        h2 {
            color: #a2a2a2;
        }
        a {
            color:#f1ecec;
        }
        a:hover {
            text-decoration: none;
            color: #000;
        }
        div {
            margin-top:60px;
        }
    </style>
</head>
<body>
<div class="wrapper">
<img src="https://s3.amazonaws.com/fully-provisioned/logo.png">
<p>
    <h2>Sequence Fibonacci Numbers:</h2>
    <?php
        $number = $_GET['n'];
        function fibonacci($number) {
            if ($number == 0)
                return 0;
            elseif ($number == 1)
                return 1;
            else
                return (fibonacci($number -1) + fibonacci($number -2));
        }
    echo fibonacci($number);
    ?>
</p>
</div>
</body>
</html>
