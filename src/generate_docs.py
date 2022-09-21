""" Generates markdown documentation from VBA docstrings
"""
import os

path = 'src/vba_scripts'

filenames = os.listdir(path)

for fn in filenames:
    if '.bas' in fn:
        name,suffix = fn.split('.')
        doc_str = f'## {name}\n'

        with open(f'src/vba_scripts/{fn}', 'r') as bas_file:
            doc = bas_file.readlines()

        for line in doc:
            if ('Public ' or 'Sub ') in line:
                doc_str += f'\n### {line}'
            elif "''' " in line:
                doc_str += line.replace("'''","")

        with open(f'docs/guide/{name}.md','w') as md_file:
            md_file.write(doc_str)
