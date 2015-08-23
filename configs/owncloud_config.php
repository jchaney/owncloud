<?php
// Default options.
$CONFIG = array (
    'installed' => false,

    // Memory caching backend configuration: APC user backend
    'memcache.local' => '\OC\Memcache\APCu',

    // Install additional applications on persistent storage.
    'apps_paths' => array (
        0 => array (
            'path'     => OC::$SERVERROOT.'/apps',
            'url'      => '/apps',
            'writable' => false,
        ),
        1 => array (
            'path'     => OC::$SERVERROOT.'/apps_persistent',
            'url'      => '/apps_persistent',
            'writable' => true,
        ),
    ),
);
