<#
.SYNOPSIS
    Start-up the PostGIS docker container(s) using "docker-compose start"
#>
param (
    # (Alias: compose_proj)
    # 
    # Set Docker Compose Project Name.
    [Alias("compose_proj")]
    [Parameter(Position = 0, ParameterSetName = "ComposeProject")]
    [String] $DOCKER_COMPOSE_PROJECT_NAME,

    # (Alias: env_file)
    # 
    # Which pre-made environment variable(s) file to use.
    [Alias("env_file")]
    [Parameter(Position = 1, ParameterSetName = "ComposeProject")]
    [String] $TEMPLATE_ENV_FILE = "dev.env",

    # (Alias: gis_db)
    # 
    # PostGis database name, default value is "dev_db"
    [Alias("gis_db")]
    [Parameter(ParameterSetName = "ComposeProject")]
    [String] $POSTGIS_NAME = "dev_db",

    # (Alias: gis_port)
    # 
    # PostGIS mapping port, default is 5432. 
    [Alias("gis_port")]
    [Parameter(ParameterSetName = "ComposeProject")]
    [int] $POSTGIS_PORT = 5432,

    # (Alias: admin_port)
    # 
    # pgAdmin4 mapping port, default is 8088. 
    [Alias("admin_port")]
    [Parameter(ParameterSetName = "ComposeProject")]
    [int] $PGADMIN_HTTP_PORT = 8088,

    # (Alias: compose_arg)
    # 
    # Command line arguments to feed into Docker Compose, default is "up -d". 
    [Alias("compose_arg")]
    [Parameter(ValueFromRemainingArguments = $true)]
    [String] $DOCKER_COMPOSE_ARGS = "up -d"
)

$compose_yml_path = Join-Path -Path "$PSScriptRoot" -ChildPath "docker-compose.yml";
Write-Debug "`$compose_yml_path='$compose_yml_path'";
$dev_env_path = Join-Path -Path "$PSScriptRoot" -ChildPath $TEMPLATE_ENV_FILE;
Write-Debug "`$dev_env_path='$dev_env_path'";
$default_env_file_path = Join-Path -Path "$PSScriptRoot" -ChildPath ".env";
Write-Debug "`$default_env_file_path='$default_env_file_path'";
Write-Debug "`$DOCKER_COMPOSE_ARGS='$DOCKER_COMPOSE_ARGS'";

if ($DOCKER_COMPOSE_PROJECT_NAME) {
    if (!(Test-Path $default_env_file_path)) {
        Write-Verbose "Create & Write COMPOSE_PROJECT_NAME environment variable to .env file...";
        New-Item -path $PSScriptRoot -name ".env" -type "file" -value "COMPOSE_PROJECT_NAME=$DOCKER_COMPOSE_PROJECT_NAME`r`n";

        Write-Verbose "Merge all environment variable into .env file...";
        Get-Content $dev_env_path | 
        ForEach-Object { $_ -replace "POSTGIS_DBNAME=.*", "POSTGIS_DBNAME=$POSTGIS_NAME" } | 
        ForEach-Object { $_ -replace "POSTGIS_PORT=.*", "POSTGIS_PORT=$POSTGIS_PORT" } | 
        ForEach-Object { $_ -replace "PGADMIN_HTTP_PORT=.*", "PGADMIN_HTTP_PORT=$PGADMIN_HTTP_PORT" } | 
        Add-Content $default_env_file_path;
    }
    else {
        Write-Verbose "Update existing .env file";
        $origin_content = Get-Content $default_env_file_path;
        $origin_content | 
        ForEach-Object { $_ -replace "COMPOSE_PROJECT_NAME=.*", "COMPOSE_PROJECT_NAME=$DOCKER_COMPOSE_PROJECT_NAME" } | 
        ForEach-Object { $_ -replace "POSTGIS_DBNAME=.*", "POSTGIS_DBNAME=$POSTGIS_NAME" } | 
        ForEach-Object { $_ -replace "POSTGIS_PORT=.*", "POSTGIS_PORT=$POSTGIS_PORT" } | 
        ForEach-Object { $_ -replace "PGADMIN_HTTP_PORT=.*", "PGADMIN_HTTP_PORT=$PGADMIN_HTTP_PORT" } | 
        Set-Content $default_env_file_path;
    }
}

if (Test-Path $default_env_file_path) {
    $execStr = "docker-compose -f $compose_yml_path $DOCKER_COMPOSE_ARGS";
}
else {
    $execStr = "docker-compose -f $compose_yml_path --env-file $dev_env_path $DOCKER_COMPOSE_ARGS";
}

Write-Verbose "$execStr"
Invoke-Expression "$execStr";