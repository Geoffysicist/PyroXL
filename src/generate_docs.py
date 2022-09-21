""" Generates markdown documentation from VBA docstrings
"""
in_fn = 'src/vba_scripts/AFDRS_dry_forest.bas'
out_fn = 'docs/guide/AFDRS_dry_forest.md'

with open(in_fn, 'r') as bas_file:
    doc = bas_file.readlines()

doc_str = '## AFDRS_dry_forest\n'
for line in doc:
    if ('Public ' or 'Sub ') in line:
        doc_str += f'\n### {line}'
    elif "''' " in line:
        doc_str += line.replace("'''","")

with open(out_fn, 'w') as doc_file:
    doc_file.write(doc_str)