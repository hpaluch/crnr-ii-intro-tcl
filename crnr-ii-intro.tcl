# 
# Project automation script for crnr-ii-intro 
# 
# Created for ISE version 14.7
# 
# This TCL script will Generate complete Xilinx ISE project under ../crnr-ii-intro_work/ directory
# Usage:
#   bash$ rm -rf ../crnr-ii-intro_work
#   bash$ xtclsh
#   xtclsh% source crnr-ii-intro.tcl
#   xtclsh% rebuild_project
#   xtclsh% exit
# You can now run Xilinx ISE 14.7 GUI (command `ise`) and open ../crnr-ii-intro_work/crnr-ii-intro.xise
#
# Why generate project with TCL? because project files are generally not suitable for
# SCM (they often contain absolute pathnames and other references (for example
# Linux vs Windows versions)

set myName "crnr-ii-intro"
# relative pointer to THIS (git managed) project
set myPrefix "../${myName}-tcl/"
# relative pointer to Generated (active project - out of git)
set myProjectDir "../${myName}_work"
set myProject "${myProjectDir}/${myName}"
set myScript "${myName}.tcl"

# 
# Main (top-level) routines
# 
# run_process
# This procedure is used to run processes on an existing project. You may comment or
# uncomment lines to control which processes are run. This routine is set up to run
# the Implement Design and Generate Programming File processes by default. This proc
# also sets process properties as specified in the "set_process_props" proc. Only
# those properties which have values different from their current settings in the project
# file will be modified in the project.
# 
proc run_process {} {

   global myScript
   global myProject

   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: running ($myProject)...\n"

   if { ! [ open_project ] } {
      return false
   }

   set_process_props
   #
   # Remove the comment characters (#'s) to enable the following commands 
   # process run "Synthesize"
   # process run "Translate"
   # process run "Map"
   # process run "Place & Route"
   #
   set task "Implement Design"
   if { ! [run_task $task] } {
      puts "$myScript: $task run failed, check run output for details."
      project close
      return
   }

   puts "Run completed (successfully)."
   project close

}

# 
# rebuild_project
# 
# This procedure renames the project file (if it exists) and recreates the project.
# It then sets project properties and adds project sources as specified by the
# set_project_props and add_source_files support procs. It recreates VHDL Libraries
# as they existed at the time this script was generated.
# 
# It then calls run_process to set process properties and run selected processes.
# 
proc rebuild_project {} {

   global myScript
   global myProject

   project close
   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: Rebuilding ($myProject)...\n"

   set proj_exts [ list ise xise gise ]
   foreach ext $proj_exts {
      set proj_name "${myProject}.$ext"
      if { [ file exists $proj_name ] } { 
         file delete $proj_name
      }
   }

   project new $myProject
   set_project_props
   add_source_files
   create_libraries
   puts "$myScript: project rebuild completed."

   run_process

}

# 
# Support Routines
# 

# 
proc run_task { task } {

   # helper proc for run_process

   puts "Running '$task'"
   set result [ process run "$task" ]
   #
   # check process status (and result)
   set status [ process get $task status ]
   if { ( ( $status != "up_to_date" ) && \
            ( $status != "warnings" ) ) || \
         ! $result } {
      return false
   }
   return true
}

# 
# show_help: print information to help users understand the options available when
#            running this script.
# 
proc show_help {} {

   global myScript

   puts ""
   puts "usage: xtclsh $myScript <options>"
   puts "       or you can run xtclsh and then enter 'source $myScript'."
   puts ""
   puts "options:"
   puts "   run_process       - set properties and run processes."
   puts "   rebuild_project   - rebuild the project from scratch and run processes."
   puts "   set_project_props - set project properties (device, speed, etc.)"
   puts "   add_source_files  - add source files"
   puts "   create_libraries  - create vhdl libraries"
   puts "   set_process_props - set process property values"
   puts "   show_help         - print this message"
   puts ""
}

proc open_project {} {

   global myScript
   global myProject

   if { ! [ file exists ${myProject}.xise ] } { 
      ## project file isn't there, rebuild it.
      puts "Project $myProject not found. Use project_rebuild to recreate it."
      return false
   }

   project open $myProject

   return true

}
# 
# set_project_props
# 
# This procedure sets the project properties as they were set in the project
# at the time this script was generated.
# 
proc set_project_props {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Setting project properties..."

   project set family "CoolRunner2 CPLDs"
   project set device "xc2c256"
   project set package "TQ144"
   project set speed "-7"
   project set top_level_module_type "HDL"
   project set synthesis_tool "XST (VHDL/Verilog)"
   project set simulator "ISim (VHDL/Verilog)"
   project set "Preferred Language" "Verilog"
   project set "Enable Message Filtering" "false"

}


# 
# add_source_files
# 
# This procedure add the source files that were known to the project at the
# time this script was generated.
# 
proc add_source_files {} {

   global myScript
   global myPrefix

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Adding sources to project..."

   xfile add "${myPrefix}CB4CE.v"
   xfile add "${myPrefix}top.ucf"
   xfile add "${myPrefix}top.v"

   # Set the Top Module as well...
   project set top "top"

   puts "$myScript: project sources reloaded."

} ; # end add_source_files

# 
# create_libraries
# 
# This procedure defines VHDL libraries and associates files with those libraries.
# It is expected to be used when recreating the project. Any libraries defined
# when this script was generated are recreated by this procedure.
# 
proc create_libraries {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Creating libraries..."


   # must close the project or library definitions aren't saved.
   project save

} ; # end create_libraries

# 
# set_process_props
# 
# This procedure sets properties as requested during script generation (either
# all of the properties, or only those modified from their defaults).
# 
proc set_process_props {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: setting process properties..."

   project set "Compiled Library Directory" "\$XILINX/<language>/<simulator>"
   project set "Preserve Unused Inputs" "false" -process "Fit"
   project set "Regenerate Core" "Under Current Project Setting" -process "Regenerate Core"
   project set "WYSIWYG" "None" -process "Synthesize - XST"
   project set "Filter Files From Compile Order" "true"
   project set "Function Block Input Limit (4-40)" "38" -process "Fit"
   project set "Last Applied Goal" "Balanced"
   project set "Last Applied Strategy" "Xilinx Default (unlocked)"
   project set "Last Unlock Status" "false"
   project set "Manual Compile Order" "false"
   project set "Clock Enable" "true" -process "Synthesize - XST"
   project set "Project Description" "Introductory blinking LEDs for Digilent CoolRunner II CPLD starter board"
   project set "Property Specification in Project File" "Store all values"
   project set "Case Implementation Style" "None" -process "Synthesize - XST"
   project set "Mux Extraction" "Yes" -process "Synthesize - XST"
   project set "FSM Encoding Algorithm" "Auto" -process "Synthesize - XST"
   project set "Optimization Goal" "Speed" -process "Synthesize - XST"
   project set "Optimization Effort" "Normal" -process "Synthesize - XST"
   project set "Resource Sharing" "true" -process "Synthesize - XST"
   project set "Use Data Gate" "true" -process "Fit"
   project set "User Browsed Strategy Files" ""
   project set "VHDL Source Analysis Standard" "VHDL-93"
   project set "Input TCL Command Script" "" -process "Generate Text Power Report"
   project set "Load Simulation File" "Default" -process "Analyze Power Distribution (XPower Analyzer)"
   project set "Load Simulation File" "Default" -process "Generate Text Power Report"
   project set "Load Setting File" "" -process "Analyze Power Distribution (XPower Analyzer)"
   project set "Load Setting File" "" -process "Generate Text Power Report"
   project set "Setting Output File" "" -process "Generate Text Power Report"
   project set "Produce Verbose Report" "false" -process "Generate Text Power Report"
   project set "Other XPWR Command Line Options" "" -process "Generate Text Power Report"
   project set "Exhaustive Fit Mode" "false" -process "Fit"
   project set "HDL Equations Style" "Source" -process "Fit"
   project set "Other CPLD Fitter Command Line Options" "" -process "Fit"
   project set "Generate Post-Fit Power Data" "false" -process "Fit"
   project set "Generate Post-Fit Simulation Model" "false" -process "Fit"
   project set "Other Programming Command Line Options" "" -process "Generate Programming File"
   project set "Maximum Signal Name Length" "20" -process "Generate IBIS Model"
   project set "Show All Models" "false" -process "Generate IBIS Model"
   project set "Target UCF File Name" "/home/ise/projects/crnr-ii-intro/top.ucf" -process "Lock Pins"
   project set "Other Ngdbuild Command Line Options" "" -process "Translate"
   project set "Other Timing Report Command Line Options" "" -process "Fit"
   project set "Other Timing Report Command Line Options" "" -process "Generate Timing"
   project set "Default Powerup Value of Registers" "Low" -process "Fit"
   project set "Collapsing Input Limit (4-40)" "32" -process "Fit"
   project set "Use Multi-level Logic Optimization" "true" -process "Fit"
   project set "Output Slew Rate" "Fast" -process "Fit"
   project set "Use Timing Constraints" "true" -process "Fit"
   project set "Input and tristate I/O Termination Mode" "Keeper" -process "Fit"
   project set "Unused I/O Pad Termination Mode" "Keeper" -process "Fit"
   project set "I/O Voltage Standard" "LVCMOS18" -process "Fit"
   project set "Implementation Template" "Optimize Density" -process "Fit"
   project set "Timing Report Format" "Summary" -process "Fit"
   project set "Timing Report Format" "Summary" -process "Generate Timing"
   project set "Use Global Clocks" "true" -process "Fit"
   project set "Use Global Output Enables" "true" -process "Fit"
   project set "Use Global Set/Reset" "true" -process "Fit"
   project set "Use Location Constraints" "Always" -process "Fit"
   project set "Create IEEE 1532 Configuration File" "false" -process "Generate Programming File"
   project set "Macro Search Path" "" -process "Translate"
   project set "Allow Unmatched LOC Constraints" "false" -process "Translate"
   project set "Allow Unmatched Timing Group Constraints" "false" -process "Translate"
   project set "Add I/O Buffers" "true" -process "Synthesize - XST"
   project set "Keep Hierarchy" "Yes" -process "Synthesize - XST"
   project set "Macro Preserve" "true" -process "Synthesize - XST"
   project set "XOR Preserve" "true" -process "Synthesize - XST"
   project set "Bus Delimiter" "<>" -process "Synthesize - XST"
   project set "Case" "Maintain" -process "Synthesize - XST"
   project set "Equivalent Register Removal" "true" -process "Synthesize - XST"
   project set "Generate RTL Schematic" "Yes" -process "Synthesize - XST"
   project set "Generics, Parameters" "" -process "Synthesize - XST"
   project set "Hierarchy Separator" "/" -process "Synthesize - XST"
   project set "HDL INI File" "" -process "Synthesize - XST"
   project set "Library Search Order" "" -process "Synthesize - XST"
   project set "Netlist Hierarchy" "As Optimized" -process "Synthesize - XST"
   project set "Use Synthesis Constraints File" "true" -process "Synthesize - XST"
   project set "Verilog Include Directories" "" -process "Synthesize - XST"
   project set "Verilog 2001" "true" -process "Synthesize - XST"
   project set "Verilog Macros" "" -process "Synthesize - XST"
   project set "Work Directory" "/home/ise/projects/crnr-ii-intro/xst" -process "Synthesize - XST"
   project set "Other XST Command Line Options" "" -process "Synthesize - XST"
   project set "Auto Implementation Compile Order" "true"
   project set "Logic Optimization" "Density" -process "Fit"
   project set "Synthesis Constraints File" "" -process "Synthesize - XST"
   project set "Maximum Number of Lines in Report" "1000" -process "Generate Text Power Report"
   project set "Output File Name" "top" -process "Generate IBIS Model"
   project set "Use Direct Input for Input Registers" "true" -process "Fit"
   project set "Collapsing Pterm Limit (3-56)" "28" -process "Fit"
   project set "Safe Implementation" "No" -process "Synthesize - XST"
   project set "Functional Model Target Language" "Verilog" -process "View HDL Source"

   puts "$myScript: project property values set."

} ; # end set_process_props

proc main {} {

   if { [llength $::argv] == 0 } {
      show_help
      return true
   }

   foreach option $::argv {
      switch $option {
         "show_help"           { show_help }
         "run_process"         { run_process }
         "rebuild_project"     { rebuild_project }
         "set_project_props"   { set_project_props }
         "add_source_files"    { add_source_files }
         "create_libraries"    { create_libraries }
         "set_process_props"   { set_process_props }
         default               { puts "unrecognized option: $option"; show_help }
      }
   }
}

if { $tcl_interactive } {
   show_help
} else {
   if {[catch {main} result]} {
      puts "$myScript failed: $result."
   }
}

