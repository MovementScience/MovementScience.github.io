humanEMG-IMSI-SI-2026.mat 

This .mat file contains single trial, bilateral raw EMG data from human subjects during 
support surface translation balance perturbations in two directions 
(subset of data from Kerr et al. 2026)

Table variables:
	Subj: unique participant ID
	Dancer: whether participant is a professional modern dancer (0=nondancer, 1=dancer)
	TrialName: trial number string
	Condition: perturbation direction (‘Fwd’ at 60% individual step threshold/‘Bkwd’ catch trial)
	AnalogFrameRate: 1000 Hz
	Time: time vector in seconds where time = 0 is perturbation onset
	EMG_TA_L_raw: Tibialis anterior (ankle dorsiflexor)
	EMG_TA_R_raw
	EMG_MGAS_L_raw: Medial gastrocnemius (ankle plantar flexor, knee flexor)
	EMG_MGAS_R_raw: 
	EMG_SOL_L_raw: Soleus (ankle plantar flexor)
	EMG_SOL_R_raw
	EMG_RF_L_raw: Rectus femoris (knee extensor, hip flexor)
	EMG_RF_R_raw
	EMG_BFLH_L_raw: Biceps femoris long head (knee flexor, hip extensor)
	EMG_BFLH_R_raw