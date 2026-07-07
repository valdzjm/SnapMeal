# Reads .env, creates the GitHub repo (if needed), and pushes.
# The token is used only for this push — it is NOT saved in .git/config.
# Usage:  powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1

$ErrorActionPreference = "Stop"
$gitExe = "C:\Program Files\Git\cmd\git.exe"
if (-not (Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path $gitExe)) {
    $env:Path = "C:\Program Files\Git\cmd;" + $env:Path
}

# --- Load .env ---
if (-not (Test-Path ".env")) { throw ".env not found. Copy .env.example to .env and fill it in." }
$cfg = @{}
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $k, $v = $_ -split '=', 2
    $cfg[$k.Trim()] = $v.Trim()
}
$pat  = $cfg["GITHUB_PAT"]
$user = $cfg["GITHUB_USERNAME"]
$repo = $cfg["GITHUB_REPO"]

if (-not $pat  -or $pat  -eq "paste-your-token-here") { throw "Set GITHUB_PAT in .env" }
if (-not $user -or $user -eq "your-github-username")  { throw "Set GITHUB_USERNAME in .env" }
if (-not $repo) { throw "Set GITHUB_REPO in .env" }

$headers = @{ Authorization = "Bearer $pat"; "User-Agent" = "SnapMeal-deploy"; Accept = "application/vnd.github+json" }

# --- Create the repo if it doesn't exist ---
try {
    Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$user/$repo" -Headers $headers | Out-Null
    Write-Host "Repo $user/$repo already exists — pushing to it."
} catch {
    Write-Host "Creating repo $user/$repo ..."
    $body = @{ name = $repo; private = $false } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $headers -Body $body -ContentType "application/json" | Out-Null
}

# --- Set a clean origin (no token) so Vercel's git integration stays valid ---
$cleanUrl = "https://github.com/$user/$repo.git"
if (git remote | Select-String -Quiet "^origin$") { git remote set-url origin $cleanUrl }
else { git remote add origin $cleanUrl }

# --- Push using the token inline (one time; not persisted) ---
$authUrl = "https://$($user):$($pat)@github.com/$user/$repo.git"
git push $authUrl main
Write-Host ""
Write-Host "Pushed to https://github.com/$user/$repo"
Write-Host "Next: import this repo at https://vercel.com/new (no build settings needed — it's static)."
