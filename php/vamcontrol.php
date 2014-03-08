<?php

$folderName =  "Group-e_v2_test";
$noticeEmailAddress = "bxgirten@brainchildren.net";

if(!file_exists("/var/www/vhosts/brainchildren.net/httpdocs/staging/vam/".$folderName)) {
    mkdir("/var/www/vhosts/brainchildren.net/httpdocs/staging/vam/".$folderName);
    chmod("/var/www/vhosts/brainchildren.net/httpdocs/staging/vam/".$folderName, 0777);
}

//print_r($_FILES);

move_uploaded_file($_FILES["userfile"]["tmp_name"],"/var/www/vhosts/brainchildren.net/httpdocs/staging/vam/".$folderName."/".$_FILES["userfile"]["name"]);

$subject = "A new file has been uploaded to the Cloud";
$message = "The file sent came in as ".$_FILES["userfile"]["tmp_name"].". It is being re-named and handled as ".$folderName."/".$_FILES["userfile"]["name"].". You can see it at http://www.brainchildren.net/staging/vam/".$folderName."/".$_FILES["userfile"]["name"];
$from = "bgirten@conferencegroup.com";
$headers = "From:" . $from;
mail($noticeEmailAddress, $subject, $message, $headers);

echo "http://www.brainchildren.net/staging/vam/".$folderName."/".$_FILES["userfile"]["name"];

?>