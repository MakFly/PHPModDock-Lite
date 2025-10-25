<?php
/**
 * PHPModDock-Lite - Services Health Check API
 * Returns JSON with status of all Docker services
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Service definitions with their ports
$services = [
    'adminer' => [
        'name' => 'Adminer',
        'port' => 8081,
        'description' => 'Database Management',
        'url' => 'http://localhost:8081'
    ],
    'redis-commander' => [
        'name' => 'Redis Commander',
        'port' => 8082,
        'description' => 'Redis Management',
        'url' => 'http://localhost:8082'
    ],
    'mailhog' => [
        'name' => 'Mailhog',
        'port' => 8025,
        'description' => 'Email Testing',
        'url' => 'http://localhost:8025'
    ],
    'dozzle' => [
        'name' => 'Dozzle',
        'port' => 8888,
        'description' => 'Docker Logs Viewer',
        'url' => 'http://localhost:8888'
    ],
    'rabbitmq' => [
        'name' => 'RabbitMQ',
        'port' => 15672,
        'description' => 'Message Queue',
        'url' => 'http://localhost:15672'
    ],
    'meilisearch' => [
        'name' => 'Meilisearch',
        'port' => 7700,
        'description' => 'Search Engine',
        'url' => 'http://localhost:7700'
    ]
];

$results = [];

foreach ($services as $key => $service) {
    $status = checkServiceHealth($service['port']);
    $results[$key] = [
        'name' => $service['name'],
        'description' => $service['description'],
        'url' => $service['url'],
        'port' => $service['port'],
        'status' => $status['status'],
        'healthy' => $status['healthy']
    ];
}

echo json_encode([
    'timestamp' => date('c'),
    'services' => $results
], JSON_PRETTY_PRINT);

/**
 * Check if a service is running by attempting to connect to its port
 */
function checkServiceHealth($port) {
    $host = 'localhost';
    $timeout = 1;

    $socket = @fsockopen($host, $port, $errno, $errstr, $timeout);

    if ($socket) {
        fclose($socket);
        return [
            'status' => 'running',
            'healthy' => true
        ];
    } else {
        return [
            'status' => 'down',
            'healthy' => false
        ];
    }
}
