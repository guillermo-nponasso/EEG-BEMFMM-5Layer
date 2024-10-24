import os
import pandas as pd

########################################
   ### PROCESS AND COMBINE TABLES ###
########################################   
   
### Read tables/ directory ###
dir_contents = os.scandir(path='tables')

# FreeSurfer Dataframes, AMR and non-AMR
amr_dataframes = []
nonamr_dataframes = []

# Headreco Dataframes, AMR and non-AMR
hr_amr_dataframes = []
hr_nonamr_dataframes = []

# 3-shell Calibration Dataframes, AMR and non-AMR
calib_amr_dataframes = []
calib_nonamr_dataframes = []

calibration_models = ['german3','swiss3', 'SimNIBS3']

all_tables7 = []

### For each patient directory combine all its tables ###
print("Processing tables. Please wait..")
for item_name in dir_contents:
    if item_name.is_dir():
        patient_path = item_name.path
        patient_dir_contents = os.scandir(path=patient_path)
        for table_entry in patient_dir_contents:
            table_path = table_entry.path
            table_filename = os.path.split(table_path)[1]

            table_df = pd.read_csv(table_path)

            # Determine if the table is AMR or not
            underscore_split  = table_filename.split('_')
            model = underscore_split[1]
            if model in calibration_models:
                if 'amr' in underscore_split:
                    df_list = calib_amr_dataframes
                else:
                    df_list = calib_nonamr_dataframes
            elif 'headreco' in underscore_split:
                if 'amr' in underscore_split:
                    all_tables7.append(table_df)
                    df_list = hr_amr_dataframes
                else:
                    df_list = hr_nonamr_dataframes
            else:
                if 'amr' in underscore_split:
                    all_tables7.append(table_df)
                    df_list = amr_dataframes
                else:
                    df_list = nonamr_dataframes
                    
            df_list.append(table_df)


cal_df = pd.concat(calib_amr_dataframes, ignore_index=True)
cal_df = cal_df.sort_values(['Patient','Model','Dipole'],ascending=(True,False,True))
cal_nonamr_df = pd.concat(calib_nonamr_dataframes, ignore_index=True)
cal_nonamr_df = cal_nonamr_df.sort_values(['Patient','Model','Dipole'],ascending=(True,False,True))

            
amr_df = pd.concat(amr_dataframes, ignore_index=True)
amr_df = amr_df.sort_values(['Patient','Model','Dipole'],ascending=(True,False,True))

nonamr_df = pd.concat(nonamr_dataframes, ignore_index=True)
nonamr_df = nonamr_df.sort_values(['Patient','Model','Dipole'], ascending=(True,False,True))

hr_amr_df = pd.concat(hr_amr_dataframes, ignore_index=True)
hr_amr_df = hr_amr_df.sort_values(['Patient','Model','Dipole'],ascending=(True,False,True))

hr_nonamr_df = pd.concat(hr_nonamr_dataframes, ignore_index=True)
hr_nonamr_df = hr_nonamr_df.sort_values(['Patient','Model','Dipole'],ascending=(True,False,True))

if not os.path.exists('stats'):
    os.mkdir('stats')

cal_df.to_csv('stats/calibration_amr.csv',index=False)
cal_nonamr_df.to_csv('stats/calibration_nonamr.csv',index=False)
amr_df.to_csv('stats/amr_tables.csv', index=False)
nonamr_df.to_csv('stats/nonamr_tables.csv', index=False)

hr_amr_df.to_csv('stats/hr_amr_tables.csv', index=False)
hr_nonamr_df.to_csv('stats/hr_nonamr_tables.csv', index=False)

all7_df = pd.concat(all_tables7, ignore_index=True)
all7_df.to_csv('stats/all_data_7shell.csv')

print("Done!")
