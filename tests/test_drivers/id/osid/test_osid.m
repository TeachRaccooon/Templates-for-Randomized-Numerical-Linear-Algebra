%{
    Main routine for running correctness tests of randomized 
   interpolative decomposition algorithms (OSID1, OSID2).

    If all tests pass, no output is present.

    Currently, avoids using logging parameter.

    Important note: 
    Before running tets, use the following:
    
    addpath('../../../../utils') - for MatrlaRandStream.m
    addpath('../../../matrix_generators/') - for matrix generator routines.
    addpath('../../../../drivers/interpolative/') - for versions of osid.
    addpath('../../../../comps/rangefinders') - for different versions of
    rangefinders.
    addpath('../../../../comps/interpolative') - for id helper routines.

%}

osid = TestOSIDs();
osid.test_simple_exact();
osid.test_simple_approx();