param(
  [string]$BaseUrl = "http://localhost:8080/api",
  [string]$Container = "aitoearn-web"
)

$ErrorActionPreference = "Stop"

$token = (docker exec $Container cat /data/init/token.txt 2>$null).Trim()
if (-not $token) {
  Write-Error "Could not read auto-login token from $Container. Is Docker running?"
}

$headers = @{
  Authorization = "Bearer $token"
  "Content-Type" = "application/json"
}

$niches = @(
  @{ name = "life_hacks"; location = "EN market - life hacks" },
  @{ name = "ai_tools"; location = "EN market - AI tools" },
  @{ name = "cooking_60s"; location = "EN market - 60s cooking" }
)

Write-Host "Seeding account groups at $BaseUrl ..."

foreach ($niche in $niches) {
  $body = $niche | ConvertTo-Json
  $response = Invoke-RestMethod -Uri "$BaseUrl/v2/channels/account-groups" -Method POST -Headers $headers -Body $body
  if ($response.code -ne 0) {
    Write-Warning "$($niche.name): $($response.message)"
  } else {
    Write-Host "OK $($niche.name) -> id $($response.data.id)"
  }
}

Write-Host "Done. Connect yt_* and tt_* accounts in Publish UI per group."
