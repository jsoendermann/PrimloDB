# TODO tidy up imports
from bottle import *
from bottle import jinja2_view as view, jinja2_template as template
from appdirs import user_data_dir
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

from os.path import *
from os import *
from glob import glob
from shutil import move, copyfile
import atexit
import re
import datetime
from uuid import uuid4
from copy import deepcopy

# TODO test with cedict data

SETTINGS_DIR = user_data_dir('PrimloDB', 'YangChuanzhang')
SETTINGS_FILENAME = join(SETTINGS_DIR, 'settings.yaml')

collections = {}
schemas = {}
settings = {}

def addExampleCollections():
    print('Creating example collections...')
    # Countries
    settings['collections_info'].append({'name': 'Countries'})
    schemas['Countries'] = [{'name': 'UUID', 'type': 'number'},
            {'name': 'Name', 'type': 'text'}, 
            {'name': 'GDP', 'type': 'number'},
            {'name': 'Cities', 'type': 'list', 'subcolumns':
                [{'name': 'Name', 'type': 'text'},
                    {'name': 'Population', 'type': 'number'},
                    {'name': 'Avg_temperature', 'type': 'number'}]}]
    collections['Countries'] = [
            {'UUID': uuid4().int, 'Name': 'France', 'GDP': 2587000000000.0, 'Cities': [
                {'Name': 'Paris', 'Population': 2273305.0, 'Avg_temperature': 12.5},
                {'Name': 'Marseille', 'Population': 850636.0, 'Avg_temperature': 15.5}]},
            {'UUID': uuid4().int, 'Name': 'Germany', 'GDP': 3820000000000.0, 'Cities': [
                {'Name': 'Cologne', 'Population': 1034175.0, 'Avg_temperature': 10.3},
                {'Name': 'Hamburg', 'Population': 1751775.0, 'Avg_temperature': 9.4},
                {'Name': 'Dresden', 'Population': 530754.0, 'Avg_temperature': 9.37}]},
            {'UUID': uuid4().int, 'Name': 'Greece', 'GDP': 271308000000.0, 'Cities': [
                {'Name': 'Athens', 'Population': 3090508.0, 'Avg_temperature': 18.5},
                {'Name': 'Thessaloniki', 'Population': 325182.0, 'Avg_temperature': 15.1}]}]

createExampleCollections = False
# create config dir if it doesn't exist
if not isdir(SETTINGS_DIR):
    makedirs(SETTINGS_DIR)

# load settings file if it exists
if isfile(SETTINGS_FILENAME):
    with open(SETTINGS_FILENAME, 'r') as settingsfile:
        settings = load(settingsfile.read(), Loader=Loader)
else:
    createExampleCollections = True
    

# set data dir to default if it doesn't exist
if not 'data_dir' in settings:
    if isdir(expanduser('~/Dropbox/')):
        data_dir = expanduser('~/Dropbox/PrimloDB data/')
    else:
        data_dir = expanduser('~/PrimloDB data/')
    if not isdir(data_dir):
        makedirs(data_dir)
    settings['data_dir'] = data_dir

# set collections info to empty array if it doesn't exist
if not 'collections_info' in settings:
    settings['collections_info'] = []

# load collections
for collection_info in settings['collections_info']:
    collection_name = collection_info['name']
    filename = join(settings['data_dir'], collection_name + '.yaml')
    if isfile(filename):
        with open(filename, 'r') as collectionfile:
            data = load(collectionfile.read(), Loader=Loader)
            collections[collection_name] = data['data']
            schemas[collection_name] = data['schema']
    else:
        collections[collection_name] = []
        schemas[collection_name] = []

if createExampleCollections:
    addExampleCollections()
    
    
# TODO create backups of collection files
# TODO timer that saves every 2 minutes
# TODO no spaces in column names
# TODO make it possible to edit data
# 
# exit handler
def exit_handler():
    print('Exiting...')

    settings_yaml = dump(settings, Dumper=Dumper)
    f = open(SETTINGS_FILENAME, 'w+')
    f.seek(0)
    f.write(settings_yaml)
    f.truncate()
    f.close()

    for collection_info in settings['collections_info']:
        filename = join(settings['data_dir'], collection_info['name'] + '.yaml')
        collection_name = collection_info['name']
        collection_yaml = dump({'schema': schemas[collection_name], 'data': collections[collection_name]}, Dumper=Dumper)
        f = open(filename, 'w+')
        f.seek(0)
        f.write(collection_yaml)
        f.truncate()
        f.close()

atexit.register(exit_handler)

@get('/')
def index():
    redirect('/collections/')

@get('/collections/')
@view('collections_list')
def collections_index():
    return {'collections_info': settings['collections_info']}

@post('/collections/')
def collections_create():
    new_name = request.forms.get('new-collection-name')
    
    # check if name is valid and new
    if not re.match('^[a-zA-Z0-9 ]+$', new_name):
        redirect('/collections/')
    for collection_info in settings['collections_info']:
        if new_name == collection_info['name']:
            redirect('/collections/')
    
    settings['collections_info'].append({'name': new_name})
    schemas[new_name] = [{'name': 'UUID', 'type': 'number'},
        {'name': 'Example_field', 'type': 'text'}]
    collections[new_name] = [
            {'UUID': uuid4().int, 'Example_field': 'First record'},
            {'UUID': uuid4().int, 'Example_field': 'Second record'}]
    


    redirect('/collections/')

def delete_field_from_dicts(dicts, field):
    for dict_ in dicts:
        del dict_[field]

def create_backup(collection_name):
    filename = join(settings['data_dir'], collection_name + '.yaml')
    if isfile(filename):
        new_collection_name = collection_name + '_backup_' + datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
        copyfile(filename, join(settings['data_dir'], new_collection_name + '.yaml'))

@get('/collections/<collection_name>/delete/')
def collections_destroy(collection_name):
    create_backup(collection_name)

    collection_info = None
    for c_info in settings['collections_info']:
        if c_info['name'] == collection_name:
            collection_info = c_info
    if collection_info:
        settings['collections_info'].remove(collection_info)
        collections.pop(collection_name)
        schemas.pop(collection_name)
    redirect('/collections/')

# this doesn't work for nested lists
def max_list_length(record):
    if isinstance(record, list):
        return sum(map(max_list_length, record))
    elif isinstance(record, dict):
        return max(map(max_list_length, record.values()))
    else:
        return 1

@get('/collections/<collection_name>/')
@view('collections_show')
def collections_show(collection_name):
    records = collections[collection_name]

    yaml_data = {'schema': schemas[collection_name], 'data': collections[collection_name]}

    collection_info_and_records = {
            'collection_name': collection_name,
            'schema': schemas[collection_name], 
            'records': [dict(record, **{'max_list_length': max_list_length(record)}) for record in records], 
            'yaml': dump(yaml_data, Dumper=Dumper)}

    #print(collection_info_and_records)
    return collection_info_and_records

def remove_object_with_uuid_from_collection(uuid, object_tree):
    #print(object_tree)
    if isinstance(object_tree, dict):
        if 'UUID' in object_tree and object_tree['UUID'] == uuid:
            return True
        else:
            for _, v in object_tree.items():
                remove_object_with_uuid_from_collection(uuid, v)
    elif isinstance(object_tree, list):
        for obj in object_tree:
            if remove_object_with_uuid_from_collection(uuid, obj):
                object_tree.remove(obj)
                return False
    return False

@post('/collections/<collection_name>/add-data/')
def collections_add_data(collection_name):
    data = request.forms.dict

    new_record = {'UUID': uuid4().int}
    
    schema = schemas[collection_name]

    for column in schema:
        if column['name'] == 'UUID':
            continue
        elif column['type'] == 'list':
            new_record[column['name']] = []
            subcolumns = column['subcolumns']
            i = 0
            while True:
                #print(data)
                first_input_name = 'input-{}.{}-{}'.format(column['name'], subcolumns[0]['name'], i)
                if not first_input_name in data:
                    break
                else:
                    subrecord = {}
                    for subcolumn in subcolumns:
                        input_name = 'input-{}.{}-{}'.format(column['name'], subcolumn['name'], i)
                        if subcolumn['type'] == 'number':
                            subrecord[subcolumn['name']] = float(request.forms[input_name])
                        else:
                            subrecord[subcolumn['name']] = request.forms[input_name]
                    new_record[column['name']].append(subrecord)
                i += 1
        else:
            raw = request.forms['input-{}'.format(column['name'])]
            if column['type'] == 'number':
                new_record[column['name']] = float(raw)
            else:
                new_record[column['name']] = raw

    collections[collection_name].append(new_record)
    # TODO CRITICAL redirect to adding tab
    redirect('/collections/{}/#add'.format(collection_name))


@get('/collections/<collection_name>/delete-data/<data_uuid>/')
def collections_delete_data(collection_name, data_uuid):
    uuid = int(data_uuid)
    
    collection = collections[collection_name]
    remove_object_with_uuid_from_collection(uuid, collection)

    redirect('/collections/{}/'.format(collection_name))

@get('/collections/<collection_name>/add-field/<field_information>/')
def collections_add_field(collection_name, field_information):
    create_backup(collection_name)

    fields_str, type_ = field_information.split(':')
    fields = fields_str.split('.')

    # edit schema
    schema = schemas[collection_name]
    if len(fields) == 1:
        schema.append({'name': fields[0], 'type': type_.lower()})
    elif len(fields) == 2:
        for field_schema in schema:
            if field_schema['name'] == fields[0]:
                field_schema['subcolumns'].append({'name': fields[1], 'type': type_.lower()})
                break
    else:
        raise ValueError('Nested lists')

    # edit data
    collection = collections[collection_name]
    if len(fields) == 1:
        for record in collection:
            record[fields[0]] = None
    elif len(fields) == 2:
        for record in collection:
            for subrecord in record[fields[0]]:
                subrecord[fields[1]] = None
    else:
        raise ValueError('Nested lists')

    redirect('/collections/{}/'.format(collection_name))


@get('/collections/<collection_name>/delete-field/<field_name>/')
def collections_delete_field(collection_name, field_name):
    create_backup(collection_name)
    
    fields = field_name.split('.')
    
    # edit schema
    schema = schemas[collection_name]
    for i in range(len(fields)-1):
        field = fields[i]
        for field_schema in schema:
            if field_schema['name'] == field:
                schema = field_schema['subcolumns']
                break
    for field_schema in schema:
        #print(fields)
        #print(schema)
        if field_schema['name'] == fields[-1]:
            schema.remove(field_schema)

    # delete data
    collection = collections[collection_name]
    if len(fields) == 1:
        delete_field_from_dicts(collection, fields[0])
    elif len(fields) == 2:
        for record in collection:
            delete_field_from_dicts(record[fields[0]], fields[1])
    else:
        raise ValueError('Nested lists')

    redirect('/collections/{}/'.format(collection_name))


# asset handlers
@route('/css/<filename>')
def css(filename):
    return static_file(filename, root='assets/css/')

@route('/js/<filename>')
def js(filename):
    return static_file(filename, root='assets/js/')

@route('/fonts/<filename>')
def fonts(filename):
    return static_file(filename, root='assets/fonts/')


run(host='localhost', port=8080, debug=True)
