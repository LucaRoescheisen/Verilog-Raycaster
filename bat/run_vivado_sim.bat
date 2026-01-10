@echo off
REM =====================================================
REM  Vivado Verilog compile & simulation script
REM  All simulation outputs stored in "sim" folder
REM =====================================================

call "D:\XilinxSoftware\2025.1\Vivado\settings64.bat"

REM --- Create and move into sim directory ---
if not exist sim mkdir sim
cd sim
echo Current directory: %cd%

REM --- Clean old files ---
if exist xsim.dir rmdir /s /q xsim.dir
if exist xvlog.log del /f /q xvlog.log
if exist xelab.log del /f /q xelab.log
if exist xsim.log del /f /q xsim.log
if exist .Xil rmdir /s /q .Xil
if exist *.pb del /f /q *.pb
if exist *.jou del /f /q *.jou

REM --- Compile all source files ---
echo =====================================================
echo Running xvlog...
echo =====================================================

REM Use absolute path to file list
call xvlog -nolog -f ../src/file_list.txt -work work
if errorlevel 1 (
    echo [ERROR] xvlog failed — check syntax.
    exit /b 1
)

REM --- Elaborate design ---
echo =====================================================
echo Running xelab...
echo =====================================================
call xelab -nolog tb_vga_top -debug typical -s tb_vga_top
if errorlevel 1 (
    echo [ERROR] xelab failed — check hierarchy or missing modules.
    exit /b 1
)

REM --- Run simulation ---
echo =====================================================
echo Launching xsim GUI...
echo =====================================================
call xsim tb_vga_top --gui
