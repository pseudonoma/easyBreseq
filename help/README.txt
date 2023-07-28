==============================================
A brief guide to "easy_breseq" - 
  A pipeline for analysing sequence-resequence
  WGS data using breseq
==============================================

The pipeline has a bash component and an R component. 
The bash scripts (in the ./sh folder) handle running breseq over a set of samples, and collating 
the individual results files into a convenient (but mostly human-unreadable) CSV list of variant 
calls. The R functions (./R) then take this CSV file and turn it into one or more tidied, cleaned, 
and human-readable CSV files for further analysis.

Run order:
----------
/sh
1. easy_breseq.sh
2. compareGDs.sh
/R
3. brsq_tidy_output()
4. brsq_QC_output()
5. brsq_easyfilter()

Instructions:
-------------
1. Open ./sh/easy_breseq.sh and read the introduction.
2. Edit the user-defined variables (see notes).
3. If the editing was done on a Windows machine, run dos2unix.
4. Run easy_breseq.sh by doing <file_path>/easy_breseq.sh (see notes).
5. Repeat Steps 1 to 4 with ./sh/compare_GDs.sh (see notes).
6. Open R.
7. Source a


Notes
-----
a.  About threads
    a rule of thumb is your machine has twice as many threads as the CPU has cores. 
    However, even if you're only running breseq, you should leave 
    one thread free for background processes to run.
    b.  Running breseq on a virtual machine (eg.)



