import mne
import matplotlib.pyplot as plt
import sklearn
from matplotlib.backends.backend_pdf import PdfPages
from mne.io import read_raw_fif
from mne import export

for i in range(1,151):
    if(i<10):
        idx = '000'+str(i)
    elif(i<100):
        idx = '00'+str(i)
    else:
        idx = '0'+str(i)
        
    # setting brainvision file name and reading into raw
    fname = "/space_lin1/quanta/sub-" + idx + "/eeg/sub-" + idx + "_ses-01_task-rest.vhdr"
    fname_alt = "/space_lin1/quanta/sub-" + idx + "/eeg/sub-" + idx + "_ses-01_resting.vhdr"
    #fname = 'subjects/sub-0334/raw/sub-0334_ses-01_task-rest.vhdr'
    try:
        raw = mne.io.read_raw_brainvision(fname,preload=True)
    except:
        print("No file found named "+fname)
        try:
            raw = mne.io.read_raw_brainvision(fname_alt,preload=True)
        except:
            print("No file found named "+fname_alt)
            continue

    # applying filters
    # raw.plot()
    raw.filter(1,None)
    raw.notch_filter([59,61])
    filtered = raw.copy()

    # filt_plot = raw.plot()

    # rereferencing the data to the ref_channels
    ref = ['TP9','TP10']
    filtered.set_eeg_reference(ref_channels = ref)
    # reref_plot = filtered.plot()

    # running ica on the data
    ica = mne.preprocessing.ICA(n_components = 29, random_state=0)
    ica.fit(filtered.copy())

    # plotting components and saving to a pdf
    fig_ica = ica.plot_components(outlines='head')

    def write_pdf(fname, figures):
        doc = PdfPages(fname)
        for fig in figures:
            fig.savefig(doc, format='pdf')
        doc.close()

    #write_pdf('final_preprocessing_scripts/pdfs/sub-0334-output.pdf',fig_ica)
    write_pdf('/home/anandn/quanta_preprocessing/pdfs/sub-'+idx+'-output.pdf',fig_ica)

    ica.exclude = [0] ## need to change this to the automated exclusion thing. check with michael.
    filtered.plot()
    ica.apply(filtered.copy(),exclude=ica.exclude).plot()

    excluded_data = ica.apply(filtered.copy(),exclude=ica.exclude)
    excluded_data.plot()

    excluded_raw = excluded_data.get_data()
    #excluded_data.save('final_preprocessing_scripts/files/sub-0334-oculomotor-removed.fif', overwrite=True)
    excluded_data.save('/home/anandn/quanta_preprocessing/oculomotor_removed/fifs/sub-'+idx+'-fro.fif', overwrite=True)

    #fro334 = read_raw_fif('final_preprocessing_scripts/files/sub-0334-oculomotor-removed.fif')
    fro334 = read_raw_fif('/home/anandn/quanta_preprocessing/oculomotor_removed/fifs/sub-'+idx+'-fro.fif')
    fro334.plot()

    # export.export_raw('final_preprocessing_scripts/files/sub-0334-fro.set', fro334)
    export.export_raw('/home/anandn/quanta_preprocessing/oculomotor_removed/sets/sub-'+idx+'-fro.set', fro334, overwrite=True)
