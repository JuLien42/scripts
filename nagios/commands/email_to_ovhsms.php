#!/usr/bin/php
<?php

##############################
# JuLien42
#
# send SMS with nagios, using OVH sms SOAP API.
#
# /etc/aliases:
#  sms:		"| /path/email_to_sms.php"
#
#
# /etc/nagios3/commands.cfg:
# define command{
#        command_name    notify-host-by-sms
#        command_line    /usr/bin/printf "%b" "$HOSTSTATE$ $HOSTNAME$ $NOTIFICATIONTYPE$ $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTPAGER$
#        }
#
#define command{
#        command_name    notify-service-by-sms
#        command_line    /usr/bin/printf "%b" "$SERVICESTATE$ $HOSTALIAS$ $SERVICEDESC$ $NOTIFICATIONTYPE$\nAddress: $HOSTADDRESS$\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTPAGER$
#        }
#
#
#############################


$login = "<login>";
$pass = "<pass>";
$account = "sms-";

$number = "<default to>";
$from = "<number or text>";


// https://github.com/plancake/official-library-php-email-parser
include('emailParser.php');


$input = stream_get_contents(STDIN);
$oEmailParser = new emailParser($input);

foreach ($oEmailParser->getTo() as $to)
	if (strpos($to, "sms+") !== false) {
		$number = substr($to, 3, strpos($to, '@') - 3);
		break;
	}
$message = $oEmailParser->getPlainBody();

file_put_contents('/tmp/sms.log', "number: ".$number."\n".$message."\n--------------------\n", FILE_APPEND);

try {
 $soap = new SoapClient("https://www.ovh.com/soapi/soapi-re-1.63.wsdl");

 //telephonySmsUserSend
 $result = $soap->telephonySmsUserSend($login, $pass, $account, $from, $number, $message, "", "", "", "", "", "", true);
 echo "telephonySmsUserSend successfull\n";
 print_r($result);
} catch(SoapFault $fault) {
 echo $fault;
}

?>

