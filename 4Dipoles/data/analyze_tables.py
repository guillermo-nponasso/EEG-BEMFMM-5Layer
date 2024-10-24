import pandas as pd
import os

def wrapper_table(f,pd, caption):
    f.write('\\begin{table}\n')
    f.write(pd.to_latex())
    f.write('\\caption{'+caption+'}\n')
    f.write('\\end{table}')

if not os.path.exists('stats'):
    print("Error: Please run firs the script 'combine_tables.py'")
else:
    pd.set_option('display.max_colwidth', None)
    pd.set_option('display.max_columns', None)

    f = open("latex_output/tables.tex","w")
    
    amr_df = pd.read_csv('stats/amr_tables.csv')
    FMD_means_amr = amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].mean().reset_index()
    FMD_std_amr = amr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance', 'Total_AMR_steps']].std().reset_index()
    #FMD_means_amr['Model'] = FMD_means_amr['Model'].apply(lambda x: '\\rowcolor{green!25}' + x if x == 'swiss7' else x)
    #FMD_std_amr.style.highlight_between(left=['SimNIBS3'], right=['SimNIBS3'],axis=1, color="#fffd75") 
    wrapper_table(f,FMD_means_amr,'AMR means \\ \\textemdash \\ FreeSurfer')
    wrapper_table(f,FMD_std_amr,'AMR Standard Deviations \\ \\textemdash \\ FreeSurfer')
    
    
    # f.write(FMD_means_amr.to_latex())
    # f.write("\n\n")
    # f.write(FMD_std_amr.to_latex())
    # f.write("\n\n")
    print("AMR FreeSurfer means, per Model and Dipole")
    print()
    print(FMD_means_amr)
    print()
    print("AMR FreeSurfer stds, per Model and Dipole")
    print(FMD_std_amr)
    print()
    print('=====================================================')
    
    nonamr_df = pd.read_csv('stats/nonamr_tables.csv')
    FMD_means_nonamr = nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].mean().reset_index()
    FMD_std_nonamr = nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].std().reset_index()

    f.write(FMD_means_nonamr.to_latex())
    f.write("\n\n")
    f.write(FMD_std_nonamr.to_latex())
    f.write("\n\n")
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

    f.write(HMD_means_amr.to_latex())
    f.write("\n\n")
    f.write(HMD_std_amr.to_latex())
    f.write("\n\n")

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
    HMD_means_nonamr = hr_nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].mean().reset_index()
    HMD_std_nonamr = hr_nonamr_df.groupby(['Model','Dipole'])[['Dist_mm', 'Angle_deg', 'Residual_Variance']].std().reset_index()

    f.write(HMD_means_nonamr.to_latex())
    f.write("\n\n")
    f.write(HMD_std_nonamr.to_latex())
    f.write("\n\n")

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

    f.write(C_means_amr.to_latex())
    f.write("\n\n")
    f.write(C_std_amr.to_latex())
    f.write("\n\n")

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
    C_means_nonamr = calib_nonamr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance']].mean().reset_index()
    C_std_nonamr = calib_nonamr.groupby(['Model','Dipole'])[['Dist_mm','Angle_deg','Residual_Variance']].std().reset_index()

    f.write(C_means_nonamr.to_latex())
    f.write("\n\n")
    f.write(C_std_nonamr.to_latex())
    f.write("\n\n")

    
    print("Calibration non-AMR means, per Model and Dipole")
    print()
    print(C_means_nonamr)
    print()
    print("Calibration non-AMR std, per Model and Dipole")
    print()
    print(C_std_nonamr)
    print()
    print('=====================================================')

    f.close()
