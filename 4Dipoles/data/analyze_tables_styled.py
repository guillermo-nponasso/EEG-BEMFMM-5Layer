# -*- coding: utf-8 -*-
"""
Created on Thu Apr 25 21:27:59 2024

@author: plai
"""
    
import pandas as pd
import os


def wrapper_table(f, pd, caption, withModel): 
    f.write('\\begin{table}\n')
    f.write('\\begin{tabular}{lllrrrr}\n')
    
    f.write('\\toprule\n')
    
    column_names = pd.columns.tolist()
    for name in column_names:
        f.write("& " + name.replace("_", "-"))  
    f.write('\\\\')
    f.write('\n')
    
    f.write('\\midrule\n')
    
    for index, row in pd.iterrows():
        if withModel:
            if 'SimNIBS' in row['Model']:
                # can change colors here
                f.write('\\rowcolor{lightgray}')
            elif 'german' in row['Model']:
                f.write('\\rowcolor{yellow}')
            elif 'swiss' in row['Model']:
                f.write('\\rowcolor{pink}')
        f.write(str(index))
        
        for name in column_names:
            row_name = row[name]
            if name == 'Model':
                row_name = row_name.replace("_", "-")
            if name == 'Residual_Variance':
                # can change display style here
                f.write(" & " + '{:.2e}'.format(row_name))
            elif name == 'Dist_mm' or name == 'Angle_deg' or name =='Total_AMR_steps':
                f.write(" & " + '{:.2f}'.format(row_name))
            else:
                f.write(" & " + str(row_name))  
        f.write('\\\\')
        f.write('\n')
 
    
    f.write('\\end{tabular}\n')
    f.write('\\caption{'+caption+'}\n')
    f.write('\\end{table}\n')
    

if not os.path.exists('stats'):
    print("Error: Please run firs the script 'combine_tables.py'")
else:
    pd.set_option('display.max_colwidth', None)
    pd.set_option('display.max_columns', None)

    f = open("latex_output/tables_styled.tex","w")
    
    f.write('\\documentclass{article}\n')
    f.write('\\usepackage{graphicx}\n')
    f.write('\\usepackage{{booktabs}}\n')
    f.write('\\usepackage[table]{xcolor}\n')
    f.write('\\title{Supplement A: Tables}\n')
    f.write('\\date{April 2024}\n')
    f.write('\\begin{document}\n')
    f.write('\\maketitle\n')
    f.write('\\setlength{\parindent}{0pt}\n\n\n')


    amr_df = pd.read_csv('stats/amr_tables.csv')
    FMD_means_amr = amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    FMD_std_amr = amr_df.groupby(['Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    wrapper_table(f,FMD_means_amr,'AMR means \\ \\textemdash \\ FreeSurfer', False)
    wrapper_table(f,FMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ FreeSurfer', False)
    
    
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
    wrapper_table(f,FMD_means_nonamr,'non-AMR means \\ \\textemdash \\ FreeSurfer', False)
    wrapper_table(f,FMD_std_nonamr,'non-AMR Standard Deviations \\ \\textemdash \\ FreeSurfer', False)
    
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
    wrapper_table(f,HMD_means_amr,'AMR means \\ \\textemdash \\ Headreco', False)
    wrapper_table(f,HMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ Headreco', False)
    
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
    wrapper_table(f,HMD_means_nonamr,'non-AMR means \\ \\textemdash \\ Headreco', False)
    wrapper_table(f,HMD_std_nonamr,'non-AMR Standard Deviations \\ \\textemdash \\ Headreco', False)
    
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
    wrapper_table(f,C_means_amr,'AMR Averages per dipole\\ \\textemdash\\ 3-shell Calibration', False);
    wrapper_table(f,C_std_amr, 'AMR Standard deviations per dipole\\ \\textemdash\\ 3-shell calibration', False)
    
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
    wrapper_table(f,C_means_nonamr,'No-AMR Averages per dipole\\ \\textemdash\\ 3-shell Calibration', False);
    wrapper_table(f,C_std_nonamr, 'No-AMR Standard deviations per dipole\\ \\textemdash\\ 3-shell calibration', False)
    
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
    wrapper_table(f,allmean_amr,'AMR means\\ \\textemdash\\ all 7-shell models', False)
    wrapper_table(f,allstd_amr,'AMR Standard Deviations\\ \\textemdash\\ all 7-shell models', False)
    
    print("ALL 7-SHELL AMR means, per Dipole")
    print()
    print(allmean_amr)
    print()
    print("ALL 7-SHELL AMR std, per Dipole")
    print()
    print(allstd_amr)
    print()
    print('=====================================================')
       
     
    amr_df = pd.read_csv('stats/amr_tables.csv')
    FMD_means_amr = amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    FMD_std_amr = amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()    
    wrapper_table(f,FMD_means_amr,'AMR means \\ \\textemdash \\ FreeSurfer', True)
    wrapper_table(f,FMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ FreeSurfer', True)

    print("AMR FreeSurfer means, per Model and Dipole")
    print()
    print(FMD_means_amr)
    print()
    print("AMR FreeSurfer stds, per Model and Dipole")
    print(FMD_std_amr)
    print()
    print('=====================================================')     


    nonamr_df = pd.read_csv('stats/nonamr_tables.csv')
    FMD_means_nonamr = nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    FMD_std_nonamr = nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    wrapper_table(f,FMD_means_nonamr,'non-AMR means \\ \\textemdash \\ FreeSurfer', True)
    wrapper_table(f,FMD_std_nonamr,'non-AMR Standard Deviations \\ \\textemdash \\ FreeSurfer', True)

    print("non-AMR FreeSurfer means, per Model and Dipole")
    print()
    print(FMD_means_nonamr)
    print()
    print("non-AMR FreeSurfer stds, per Model and Dipole")
    print(FMD_std_nonamr)
    print()
    print('=====================================================')
    
    
    hr_amr_df = pd.read_csv('stats/hr_amr_tables.csv')
    HMD_means_amr = hr_amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    HMD_std_amr = hr_amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    wrapper_table(f,HMD_means_amr,'AMR means \\ \\textemdash \\ Headreco', True)
    wrapper_table(f,HMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ Headreco', True)

    print("AMR Headreco means, per Model and Dipole")
    print()
    print(HMD_means_amr)
    print()
    print("AMR Headreco stds, per Model and Dipole")
    print()
    print(HMD_std_amr)
    print()
    print('=====================================================')

    
    hr_nonamr_df = pd.read_csv('stats/hr_nonamr_tables.csv')
    HMD_means_nonamr = hr_nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    HMD_std_nonamr = hr_nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    wrapper_table(f,HMD_means_nonamr,'non-AMR means \\ \\textemdash \\ Headreco', True)
    wrapper_table(f,HMD_std_nonamr,'non-AMR Standard Deviations \\ \\textemdash \\ Headreco', True)

    print("non-AMR Headreco means, per Model and Dipole")
    print()
    print(HMD_means_nonamr)
    print()
    print("non-AMR Headreco stds, per Model and Dipole")
    print()
    print(HMD_std_nonamr)
    print()
    print('=====================================================')


    calib_amr = pd.read_csv('stats/calibration_amr.csv')
    C_means_amr = calib_amr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].mean().reset_index()
    C_std_amr = calib_amr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].std().reset_index()
    wrapper_table(f,C_means_amr,'AMR means \\ \\textemdash \\ Calibration', True)
    wrapper_table(f,C_std_amr,'AMR Standard Deviations \\ \\textemdash \\ Calibration', True)

    print("Calibration AMR means, per Model and Dipole")
    print()
    print(C_means_amr)
    print()
    print("Calibration AMR std, per Model and Dipole")
    print()
    print(C_std_amr)
    print()
    print('=====================================================')


    calib_nonamr = pd.read_csv('stats/calibration_nonamr.csv')
    C_means_nonamr = calib_nonamr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].mean().reset_index()
    C_std_nonamr = calib_nonamr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance','Total_AMR_steps']].std().reset_index()
    wrapper_table(f,C_means_nonamr,'non-AMR means \\ \\textemdash \\ Calibration', True)
    wrapper_table(f,C_std_nonamr,'non-AMR Standard Deviations \\ \\textemdash \\ Calibration', True)

    print("Calibration non-AMR means, per Model and Dipole")
    print()
    print(C_means_nonamr)
    print()
    print("Calibration non-AMR std, per Model and Dipole")
    print()
    print(C_std_nonamr)
    print()
    print('=====================================================')
    
    
    f.write('\\end{document}\n')
    f.close()


