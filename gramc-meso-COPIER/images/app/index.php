<?php

use App\Kernel;
use Symfony\Component\ErrorHandler\Debug;
use Symfony\Component\HttpFoundation\Request;

require dirname(__DIR__).'/config/bootstrap.php';

if ($_SERVER['APP_DEBUG']) {
    umask(0000);
    Debug::enable();
}

if ($trustedProxies = $_SERVER['TRUSTED_PROXIES'] ?? false) {
    Request::setTrustedProxies(explode(',', $trustedProxies), Request::HEADER_X_FORWARDED_FOR | Request::HEADER_X_FORWARDED_PORT | Request::HEADER_X_FORWARDED_PROTO);
}

If ($trustedHosts = $_SERVER['TRUSTED_HOSTS'] ?? false) {
    Request::setTrustedHosts([$trustedHosts]);
}

if ($_SERVER['APP_ENV'] == 'dev')
{
	if (isset($_SERVER['HTTP_CLIENT_IP']))
	{
	    header('HTTP/1.0 403 Forbidden');
	    exit('You are not allowed to access this file. Check '.basename(__FILE__).' for more information. Your address is '.@$_SERVER['HTTP_X_REAL_IP']);
	}
}
else
{
	if (isset($_SERVER['HTTP_CLIENT_IP'])
	    || php_sapi_name() === 'cli-server')
	{
	    header('HTTP/1.0 403 Forbidden');
	    exit('You are not allowed to access this file. Check '.basename(__FILE__).' for more information. Your address is '.@$_SERVER['HTTP_X_REAL_IP']);
	}
}

$kernel = new Kernel($_SERVER['APP_ENV'], (bool) $_SERVER['APP_DEBUG']);
$request = Request::createFromGlobals();

// cf. https://symfony.com/doc/5.4/deployment/proxies.html
Request::setTrustedProxies(['192.168.0.0/16'],Request::HEADER_X_FORWARDED_FOR|Request::HEADER_X_FORWARDED_PORT|Request::HEADER_X_FORWARDED_PROTO|Request::HEADER_X_FORWARDED_PREFIX);

$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
