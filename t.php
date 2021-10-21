#!/usr/bin/php -f
<?php
$a = array(1,2,3,4,5);
$b = array(6,7,8,9,10);

$a = array_merge($a,$b);

print 'array_merge($a,$b):' . "\n";
var_dump($a);

$a = array(1,2,3,4,5);
$a = array_slice($a,2);

print "\n";
print 'array_slice($a,2)' . "\n";
var_dump($a);

$a = array(1,2,3,4,5);
$a = array_merge($a,array_slice($b,0,2));
$b = array_slice($b,2);

print "\n";
print 'array_merge($a,array_slice($b,0,2))' . "\n";
print 'array_slice($b,2)' . "\n";
var_dump($a);
var_dump($b);

?>
