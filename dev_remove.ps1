<#
.SYNOPSIS
    Stop & Remove currnet PostGIS docker container(s) using "docker-compose down"
#>
param (
    # (Alias: env_file)
    # 
    # Which pre-made environment variable(s) file to use.
    [Alias("env_file")]
    [Parameter(Position = 0, ParameterSetName = "ComposeProject")]
    [String] $TEMPLATE_ENV_FILE = "dev.env",

    # (Alias: compose_arg)
    # 
    # Other additional command line arguments to feed into Docker Compose.
    [Alias("compose_arg")]
    [Parameter(ValueFromRemainingArguments = $true)]
    [String] $DOCKER_COMPOSE_OTHER_ARGS
)

$compose_yml_path = Join-Path -Path "$PSScriptRoot" -ChildPath "docker-compose.yml";
Write-Debug "`$compose_yml_path='$compose_yml_path'";
$dev_env_path = Join-Path -Path "$PSScriptRoot" -ChildPath $TEMPLATE_ENV_FILE;
Write-Debug "`$dev_env_path='$dev_env_path'";
$default_env_file_path = Join-Path -Path "$PSScriptRoot" -ChildPath ".env";
Write-Debug "`$default_env_file_path=$default_env_file_path";

if (Test-Path $default_env_file_path) {
    $execStr = "docker-compose -f $compose_yml_path down";
}
else {
    $execStr = "docker-compose -f $compose_yml_path --env-file $PSScriptRoot/dev.env down";
}

if ($DOCKER_COMPOSE_OTHER_ARGS) {
    $execStr = $execStr + " $DOCKER_COMPOSE_OTHER_ARGS"
}

Write-Verbose "$execStr"
Invoke-Expression "$execStr";