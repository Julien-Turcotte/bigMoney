# MiniUniswap DEX Stop Script for Windows
# This script stops all running services

Write-Host "🛑 Stopping MiniUniswap DEX services..." -ForegroundColor Yellow
Write-Host ""

# Function to kill process on port
function Stop-ProcessOnPort {
    param(
        [int]$Port,
        [string]$ServiceName
    )
    try {
        $connections = @(Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue)
        if ($connections) {
            $processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
            foreach ($processId in $processIds) {
                $processName = (Get-Process -Id $processId -ErrorAction SilentlyContinue).ProcessName
                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                Write-Host "✓ Stopped $ServiceName (PID: $processId, Process: $processName)" -ForegroundColor Green
            }
            return $true
        } else {
            Write-Host "  $ServiceName not running on port $Port" -ForegroundColor Gray
            return $false
        }
    } catch {
        Write-Host "  $ServiceName not running on port $Port" -ForegroundColor Gray
        return $false
    }
}

# Stop all PowerShell background jobs related to the DEX
Write-Host "Checking for background jobs..." -ForegroundColor Cyan
$jobs = Get-Job | Where-Object { $_.State -eq "Running" }
if ($jobs) {
    foreach ($job in $jobs) {
        Write-Host "✓ Stopping job: $($job.Name) (ID: $($job.Id))" -ForegroundColor Green
        Stop-Job $job
        Remove-Job $job
    }
} else {
    Write-Host "  No running background jobs found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Checking for services on ports..." -ForegroundColor Cyan

# Stop services on known ports
$stoppedAny = $false
$stoppedAny = (Stop-ProcessOnPort -Port 8545 -ServiceName "Hardhat Node") -or $stoppedAny
$stoppedAny = (Stop-ProcessOnPort -Port 3000 -ServiceName "Frontend (port 3000)") -or $stoppedAny
$stoppedAny = (Stop-ProcessOnPort -Port 5173 -ServiceName "Frontend (port 5173)") -or $stoppedAny

Write-Host ""
if ($stoppedAny) {
    Write-Host "✅ All services stopped successfully!" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No services were running" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "MiniUniswap DEX services have been stopped. 👋" -ForegroundColor Cyan
