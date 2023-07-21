from tkinter import *
from tkinter import ttk
from tkinter.filedialog import asksaveasfile
from tkinter.filedialog import askopenfile

def open():
    file = askopenfile(mode = 'r', filetypes=[('JSON', '*.json')])
    if file is not None:
        json_old = file.read()
        json_new = json_old.replace("\"notes\"", "\"sections\"").replace("\"sectionNotes\"", "\"notes\"")
        print(json_new)

open()