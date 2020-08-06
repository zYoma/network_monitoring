#!/usr/bin/perl



use strict;
use Fcntl;
use CGI;
use 5.010;
my $my_cgi;
my $line;
my $event = 'event_on_mu.txt';



print "Content-type: text/html\n\n";
 $my_cgi = new CGI;

 


 print qq~
<html>
<head>
 <link rel="stylesheet" href="http://10.40.254.109/op/bootstrap/css/bootstrap.min.css" >

<link href="access.css" rel="stylesheet">
<script type="text/javascript" src="jquery.js"></script>  
</head>
<body style = "background-color: #ECF6CE;">




<br>
<div class ="col-7">
<div class="alert alert-danger" role="alert">
  -Список адресов по каждому из городов автоматически синхронизируется с Nioss один раз в сутки.<br>
  -Устройства автоматически опрашиваются на предмет аварий раз в 10 мин. <br>-При выборе конкретного устройства происходит мгновенный опрос параметров.<br>
  -Поиск по адресу Ctrl+F
</div>
</div>








<div id="log"><br><br>
<div class="d-flex justify-content-center">
<div class="spinner-grow text-info  d-none" role="status">
  <span class="sr-only">Loading...</span>
</div>
</div>
</div>  

<script>  
        function show()  
        {  
           \$.ajax({  
                url: "in_2.pl",  
                cache: false, 
				
	beforeSend: function () {					// выполнить перед началом загрузки
			\$('.spinner-grow').removeClass('d-none');
		
		},
		complete: function () {						//выполнить по окончанию загрузки
    
			\$('.spinner-grow').addClass('d-none');
		},
		
                success: function(html){  
                    \$("#log").html(html);  
                }  
            });  
        }  
      
        \$(document).ready(function(){  
            show();  
            setInterval('show()',30000);  
        });  
    </script>  
	
	



<div id=\"zyoma\">nnzimin\@mts.ru</div>
</body></html>
	
</body>
</html> 
~;


