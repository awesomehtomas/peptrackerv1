# Auto-sync the peptide tracker to GitHub.
# Invoked by the Claude Code "Stop" hook after each turn: stages any changes,
# commits them (timestamped) if there are any, and pushes to origin/main.
# A plain `git push` at the end also retries any commit that failed to push earlier.
$ErrorActionPreference = "Continue"
Set-Location -Path (Join-Path $PSScriptRoot "..")

git add -A | Out-Null
$pending = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($pending)) {
    $msg = "auto-sync: " + (Get-Date -Format "yyyy-MM-dd HH:mm")
    git commit -m $msg | Out-Null
}
git push origin main | Out-Null
exit 0
