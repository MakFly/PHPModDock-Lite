<?php
/**
 * PHPModDock-Lite - Projects API
 * Auto-detect projects from /var/www directory
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Project types and their detection patterns (order matters - most specific first)
$projectTypes = [
    'laravel' => [
        'name' => 'Laravel',
        'icon' => 'laravel',
        'color' => 'from-red-500 to-red-600',
        'description' => 'PHP Framework for Web Artisans',
        'detection' => ['artisan', 'bootstrap/app.php'],
        'subdomain' => '.localhost',
        'path' => ''
    ],
    'symfony' => [
        'name' => 'Symfony',
        'icon' => 'symfony',
        'color' => 'from-gray-700 to-gray-800',
        'description' => 'High Performance PHP Framework',
        'detection' => ['symfony.lock', 'bin/console'],
        'subdomain' => '.localhost',
        'path' => '/api'
    ],
    'prestashop' => [
        'name' => 'PrestaShop',
        'icon' => 'prestashop',
        'color' => 'from-blue-500 to-blue-600',
        'description' => 'E-commerce Platform',
        'detection' => ['classes/PrestaShopAutoload.php', 'modules'],
        'subdomain' => '.localhost',
        'path' => ''
    ],
    'wordpress' => [
        'name' => 'WordPress',
        'icon' => 'wordpress',
        'color' => 'from-blue-400 to-blue-500',
        'description' => 'Content Management System',
        'detection' => ['wp-config.php', 'wp-content'],
        'subdomain' => '.localhost',
        'path' => ''
    ]
];

/**
 * Detect project type based on files/directories
 */
function detectProjectType($projectPath, $projectTypes) {
    foreach ($projectTypes as $type => $config) {
        $matches = 0;
        foreach ($config['detection'] as $marker) {
            if (file_exists($projectPath . '/' . $marker)) {
                $matches++;
            }
        }
        // If at least 2 detection markers match, consider it this type
        if ($matches >= 2) {
            return $type;
        }
    }
    return 'generic';
}

/**
 * Get project information
 */
function getProjectInfo($projectName, $projectPath, $projectTypes) {
    $type = detectProjectType($projectPath, $projectTypes);

    $config = $projectTypes[$type] ?? [
        'name' => 'Project',
        'icon' => 'generic',
        'color' => 'from-gray-500 to-gray-600',
        'description' => 'Web Application',
        'subdomain' => '.localhost',
        'path' => ''
    ];

    // Generate domain name (convert underscores/spaces to hyphens)
    $domain = strtolower(preg_replace('/[_\s]+/', '-', $projectName));

    return [
        'name' => $projectName,
        'displayName' => ucwords(str_replace(['-', '_'], ' ', $projectName)),
        'type' => $type,
        'framework' => $config['name'],
        'description' => $config['description'],
        'url' => 'http://' . $domain . $config['subdomain'] . $config['path'],
        'domain' => $domain . $config['subdomain'],
        'icon' => $config['icon'],
        'color' => $config['color'],
        'path' => $projectPath
    ];
}

// Scan projects directory
$projectsDir = '/var/www';
$projects = [];

try {
    if (!is_dir($projectsDir)) {
        throw new Exception('Projects directory not found');
    }

    $dirs = scandir($projectsDir);

    foreach ($dirs as $dir) {
        // Skip hidden dirs and parent dirs
        if ($dir === '.' || $dir === '..' || $dir[0] === '.') {
            continue;
        }

        $projectPath = $projectsDir . '/' . $dir;

        // Only process directories
        if (!is_dir($projectPath)) {
            continue;
        }

        // Get project info
        $projects[] = getProjectInfo($dir, $projectPath, $projectTypes);
    }

    echo json_encode([
        'success' => true,
        'count' => count($projects),
        'projects' => $projects
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
