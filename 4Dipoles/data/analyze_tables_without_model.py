
import pandas as pd
import os

def wrapper_table(f,pd, caption):
    
    f.write('\\begin{table}\n')
    f.write(pd.to_latex())
    f.write('\\caption{'+caption+'}\n')
    f.write('\\end{table}\n\n')


    

if not os.path.exists('stats'):
    print("Error: Please run firs the script 'combine_tables.py'")
else:
    pd.set_option('display.max_colwidth', None)
    pd.set_option('display.max_columns', None)
    
    #### OUTPUT FILE ####
    f=open('latex_output/tables_nomodel.tex','w')
    #####################
    
    
    amr_df = pd.read_csv('stats/amr_tables.csv')
    FMD_means_amr = amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    FMD_std_amr = amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    wrapper_table(f,FMD_means_amr,'AMR means \\ \\textemdash \\ FreeSurfer')
    wrapper_table(f,FMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ FreeSurfer')
    
    
    print("AMR FreeSurfer means, per Dipole")
    print()
    print(FMD_means_amr)
    print()
    print("AMR FreeSurfer stds, per Dipole")
    print(FMD_std_amr)
    print()
    print('=====================================================')
    
    nonamr_df = pd.read_csv('stats/nonamr_tables.csv')
    FMD_means_nonamr = nonamr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].mean().reset_index()
    FMD_std_nonamr = nonamr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].std().reset_index()
    wrapper_table(f,FMD_means_nonamr,'AMR means \\ \\textemdash \\ FreeSurfer')
    wrapper_table(f,FMD_std_nonamr,'AMR Standard Deviations \\ \\textemdash \\ FreeSurfer')
    
    print("non-AMR FreeSurfer means, per Dipole")
    print()
    print(FMD_means_nonamr)
    print()
    print("non-AMR FreeSurfer stds, per Dipole")
    print(FMD_std_nonamr)
    print()
    print('=====================================================')
    
    
    hr_amr_df = pd.read_csv('stats/hr_amr_tables.csv')
    HMD_means_amr = hr_amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    HMD_std_amr = hr_amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()    
    wrapper_table(f,HMD_means_amr,'AMR means \\ \\textemdash \\ Headreco')
    wrapper_table(f,HMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ Headreco')

    print("AMR Headreco means, pee Dipole")
    print()
    print(HMD_means_amr)
    print()
    print("AMR Headreco stds, per Dipole")
    print()
    print(HMD_std_amr)
    print()
    print('=====================================================')
    
    hr_nonamr_df = pd.read_csv('stats/hr_nonamr_tables.csv')
    HMD_means_nonamr = hr_nonamr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].mean().reset_index()
    HMD_std_nonamr = hr_nonamr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].std().reset_index()
    wrapper_table(f,HMD_means_nonamr,'AMR means \\ \\textemdash \\ Headreco')
    wrapper_table(f,HMD_std_nonamr,'AMR Standard Deviations \\ \\textemdash \\ Headreco')

    print("non-AMR Headreco means, per Dipole")
    print()
    print(HMD_means_nonamr)
    print()
    print("non-AMR Headreco stds, per Dipole")
    print()
    print(HMD_std_nonamr)
    print()
    print('=====================================================')


    calib_amr = pd.read_csv('stats/calibration_amr.csv')
    C_means_amr = calib_amr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].mean().reset_index()
    C_std_amr = calib_amr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].std().reset_index()    
    wrapper_table(f,C_means_amr,'AMR Averages per dipole\\ \\textemdash\\ 3-shell Calibration');
    wrapper_table(f,C_std_amr, 'AMR Standard deviations per dipole\\ \\textemdash\\ 3-shell calibration')
    
    print("Calibration AMR means, per Dipole")
    print()
    print(C_means_amr)
    print()
    print("Calibration AMR std, per Dipole")
    print()
    print(C_std_amr)
    print()
    print('=====================================================')

    calib_nonamr = pd.read_csv('stats/calibration_nonamr.csv')
    C_means_nonamr = calib_nonamr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance']].mean().reset_index()
    C_std_nonamr = calib_nonamr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance']].std().reset_index()    
    wrapper_table(f,C_means_nonamr,'No-AMR Averages per dipole\\ \\textemdash\\ 3-shell Calibration');
    wrapper_table(f,C_std_nonamr, 'No-AMR Standard deviations per dipole\\ \\textemdash\\ 3-shell calibration')
    
    print("Calibration non-AMR means, per Dipole")
    print()
    print(C_means_nonamr)
    print()
    print("Calibration non-AMR std, per Dipole")
    print()
    print(C_std_nonamr)
    print()
    print('=====================================================')


    all_amr = pd.read_csv('stats/all_data_7shell.csv')
    allmean_amr = all_amr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].mean().reset_index()
    allstd_amr = all_amr.groupby(['Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].std().reset_index()
    wrapper_table(f,allmean_amr,'AMR means\\ \\textemdash\\ all 7-shell models')
    wrapper_table(f,allstd_amr,'AMR Standard Deviations\\ \\textemdash\\ all 7-shell models')
    
    print("ALL 7-SHELL AMR means, per Dipole")
    print()
    print(allmean_amr)
    print()
    print("ALL 7-SHELL AMR std, per Dipole")
    print()
    print(allstd_amr)
    print()
    print('=====================================================')

   
    f.close()
