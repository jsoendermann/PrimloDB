{% extends "layout.html" %}

<!-- TODO tidy up macros -->

{% macro renderSchema(columnsInfo, prefix='') %}
    <ul>
        {% for columnInfo in columnsInfo %}
            {% if not columnInfo.name == 'UUID' %}
                <li>
                    <b>{{ columnInfo.name }}</b>
                    ({{ columnInfo.type }})

                     <!--a href="#"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span></a--> 
                     <a class="delete-field-link" id="delete-{{ prefix }}{{ columnInfo.name }}" href="javascript:void(0);">
                        <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                      </a>

                    {% if columnInfo.type == 'list' %}
                        {{ renderSchema(columnInfo.subcolumns, columnInfo.name + '.') }}
                    {% endif %}
                </li>
            {% endif %}
        {% endfor %}
        <li>
        <!-- TODO this produces ugly ids -->
          <button type="button" class="btn btn-primary btn-xs add-field-button" id="add-to-{{ prefix }}">
            <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>
          </button>
        </li>
        
        <!--li><a href="#"><span class="glyphicon glyphicon-plus" aria-hidden="true"></span></a></li-->
    </ul>
{%- endmacro %}






{% macro renderTableHead(prefix, columnsInfo) %}
    {%- for columnInfo in columnsInfo -%}
        {%- if columnInfo.name == 'UUID' %}
            <!-- UUID -->
        {%- elif columnInfo.type == 'list' -%}
            {{ renderTableHead(columnInfo.name + '.', columnInfo.subcolumns) }}
        {%- else -%}
            <th>
                {%- if prefix -%}
                    <span style="color: #BBBBBB;">{{ prefix }}</span>
                    <br>
                {%- endif -%}
                
                {{ columnInfo.name }}
            </th>
        {%- endif -%}
    {%- endfor -%}
{% endmacro %}





{% macro renderList(listData, listSchema) %}
    {% for columnInfo in listSchema %}
    
        {% if columnInfo['name'] != 'UUID' %}
            <td>
            {% if listData[columnInfo['name']] %}
                {{ listData[columnInfo['name']] }}
            {% else %}
                <span style="color: #AAA;">-</span>
            {% endif %}
            </td>
        {% endif %}
    
    {% endfor %}
{% endmacro %}




{% macro renderRecord(record, listIndex) %}
    <tr>
        {% for columnInfo in collection_info.schema %}
            {% if columnInfo['name'] == 'UUID' %}    
                <!-- UUID -->
            {% elif columnInfo.type == 'list' and listIndex == 0 and record[columnInfo['name']]|length == 0 %}
                <td colspan="{{ columnInfo.subcolumns|length }}"><span style="color: #AAA;">-</span></td>
            {% elif columnInfo.type == 'list' and listIndex < record[columnInfo['name']]|length %}
                {{ renderList(record[columnInfo['name']][listIndex], columnInfo.subcolumns) }}
            {% elif listIndex == 0 %}
                <td rowspan="{{ record.max_list_length }}" >
                    {% if record[columnInfo['name']] %}
                        {{ record[columnInfo['name']] }}
                    {% else %}
                        <span style="color: #AAA;">-</span>
                    {% endif %}
                </td>
            {% endif %}
        {% endfor %}

        {% if listIndex == 0 %}
            <td rowspan="{{ record.max_list_length }}">
                <!--button type="button" id="edit-{{record['UUID']}}" class="btn btn-default btn-xs"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span></button-->
                <button type="button" id="delete-{{record['UUID']}}" class="btn btn-danger btn-xs delete-data-button"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></button>
            </td>
        {% endif %}
    </tr>

    {% if listIndex < record.max_list_length - 1 %}
    {{ renderRecord(record, listIndex + 1) }}
    {% endif %}

{% endmacro %}




<!-- TODO don't use . in class and id names -->
{% macro renderAddingForm(columnsInfo) %}
    {% for columnInfo in columnsInfo %}
        {% if columnInfo.name == 'UUID' %}
        {% elif columnInfo.type == 'list' %}
            <label>{{ columnInfo.name }}:</label>
            <div id="{{ columnInfo.name }}-section" style="border-color: #ddd; border-width: 1px; border-radius: 4px 4px 0 0; border-style: solid; padding: 15px 10px 15px;">
                <div id="{{ columnInfo.name }}-section-inner">
                <div id="{{ columnInfo.name }}-TEMPLATE" class="hidden">
                    {% for listColumnInfo in columnInfo.subcolumns %}
                        <div class="form-group">
                            <input class="form-control
                                          input-field 
                                          input-type-{{ listColumnInfo.type}}
                                          input-{{ columnInfo.name }}.{{ listColumnInfo.name }}"
                                   id="input-{{ columnInfo.name }}.{{ listColumnInfo.name }}-0"
                                   placeholder="{{ listColumnInfo.name }}">
                            <p class="help-block hidden" id="error-message-{{ columnInfo.name }}.{{ listColumnInfo.name }}" style="color: #a94442;">%Error%</p>
                        </div>
                    {% endfor %}
                </div>
                </div>

                <input class="form-control append-to-list-input" 
                       id="append-to-{{ columnInfo.name }}" 
                       placeholder="Start typing to add an element to <{{ columnInfo.name }}>">
            </div>
            <br>
        {% else %}

            <div class="form-group">
                <input class="form-control
                              input-field 
                              input-type-{{ columnInfo.type}} 
                              input-{{ columnInfo.name }}"
                       name="input-{{ columnInfo.name }}"
                       placeholder="{{ columnInfo.name }}">
                <p class="help-block hidden" id="error-message-{{ columnInfo.name }}" style="color: #a94442;">%Error%</p>
            </div>

        {% endif %}
                  
    {% endfor %}
{% endmacro %}





{% block content %}

<!-- TODO move this up to the header -->
<div class="row">
          <div class="col-md-12">
              <h3 class="text-center" id="collection-name">{{ collection_name }}</h3>
          </div>
      </div>


<div class="row">
<div class="col-md-12">


<div role="tabpanel">
   <div style="padding-bottom: 20px;">
      <ul class="nav nav-tabs" role="tablist">
         <li role="presentation" class="active"><a href="#data" aria-controls="data" role="tab" data-toggle="tab">Browse</a></li>
         <li role="presentation"><a href="#add" aria-controls="add" role="tab" data-toggle="tab">Add data</a></li>
         <li role="presentation"><a href="#schema" aria-controls="schema" role="tab" data-toggle="tab">Data format</a></li>
         <li role="presentation"><a href="#yaml" aria-controls="yaml" role="tab" data-toggle="tab">YAML</a></li>
         <li role="presentation"><a href="#settings" aria-controls="settings" role="tab" data-toggle="tab">Settings</a></li>
      </ul>
   </div>





   <!-- Tab panes -->
   <div class="tab-content">
      <div role="tabpanel" class="tab-pane active" id="data">
         <table class="table table-bordered table-condensed">
            <thead>
               <tr>
                  {{ renderTableHead('', collection_info.schema) }}
                  <th><!-- edit buttons --></th>
               </tr>
            </thead>
            <tbody>
                {% for record in records %}
                    {{ renderRecord(record, 0) }}
                {% endfor %}
            </tbody>
         </table>
      </div>



      <div role="tabpanel" class="tab-pane" id="add">
         <div class="row">
            <div class="col-md-6">
               <h3>New Record</h3>
               <div style="border-color: #ddd; border-width: 1px; border-radius: 4px 4px 0 0; border-style: solid; padding: 15px 10px 15px;">

               <form id="add-data-form" action="/collections/{{collection_name}}/add-data/" method="post">
                  {{ renderAddingForm(collection_info.schema) }}
                  <br>
                  <button class="btn btn-primary" type="submit">Add Record</button>
               </form>

               </div>
            </div>
            <div class="col-md-6">
               <h3>About</h3>
               <p>
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras lacus tortor, pulvinar et convallis dictum, pulvinar vitae sapien. Proin consectetur quis odio ac iaculis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla non sapien nec nisi pharetra ornare vitae eu tortor. Cras in rhoncus nulla. Fusce pharetra, lectus et accumsan tristique, arcu neque congue lacus, sit amet pellentesque ligula odio id massa. Maecenas sit amet enim sit amet mauris facilisis tristique ultricies sed lorem. Etiam justo magna, aliquam vitae eros rhoncus, viverra condimentum tortor. Cras vehicula sed lacus vitae lacinia.
               </p>
               <p>
                  Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed et accumsan sem, ac dignissim ipsum. Fusce hendrerit massa ac diam mollis, vitae ullamcorper quam bibendum. Vestibulum eget nisi quis libero porta lacinia in non nunc. Curabitur pretium finibus velit non tincidunt. Nullam volutpat augue in condimentum interdum. Ut in euismod nulla. Suspendisse vitae arcu magna. Aenean a ipsum eu mauris pellentesque convallis eu ut ipsum. Donec euismod sit amet sapien vel elementum. Donec quis consequat libero.
               </p>
            </div>
         </div>
      
      </div>





      <div role="tabpanel" class="tab-pane" id="schema">
         <div class="row">
            <div class="col-md-6">
               <h3>Data Format</h3>
               {{ renderSchema(collection_info.schema) }}
            </div>
            <div class="col-md-6">
               <h3>About</h3>
               <p>
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras lacus tortor, pulvinar et convallis dictum, pulvinar vitae sapien. Proin consectetur quis odio ac iaculis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla non sapien nec nisi pharetra ornare vitae eu tortor. Cras in rhoncus nulla. Fusce pharetra, lectus et accumsan tristique, arcu neque congue lacus, sit amet pellentesque ligula odio id massa. Maecenas sit amet enim sit amet mauris facilisis tristique ultricies sed lorem. Etiam justo magna, aliquam vitae eros rhoncus, viverra condimentum tortor. Cras vehicula sed lacus vitae lacinia.
               </p>
               <p>
                  Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed et accumsan sem, ac dignissim ipsum. Fusce hendrerit massa ac diam mollis, vitae ullamcorper quam bibendum. Vestibulum eget nisi quis libero porta lacinia in non nunc. Curabitur pretium finibus velit non tincidunt. Nullam volutpat augue in condimentum interdum. Ut in euismod nulla. Suspendisse vitae arcu magna. Aenean a ipsum eu mauris pellentesque convallis eu ut ipsum. Donec euismod sit amet sapien vel elementum. Donec quis consequat libero.
               </p>
            </div>

            <!-- Modal -->
<div class="modal fade" id="addFieldModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Add field</h4>
      </div>
      <div class="modal-body">
        <form>
        <div class="form-group">
    <label for="name">Name</label>
    <input class="form-control" id="new-field-name" placeholder="Field name..." />
    </div>
    <div class="form-group">
    <label for="type">Type</label>

    <select class="form-control" id="add-to-toplevel-types">
    <option>Text</option>
    <option>Number</option>
    <option>List</option>
    </select>
    
    <select class="form-control hidden" id="add-to-list-types">
    <option>Text</option>
    <option>Number</option>
    </select>

    <input type="hidden" name="add-to" id="add-to" value="">

</div>
</form>

      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" id="add-field-modal-button">Add</button>
      </div>
    </div>
  </div>
</div>

         </div>
      </div>


      <div role="tabpanel" class="tab-pane" id="yaml">
        <!-- TODO option to display w/o uuids -->
        <textarea class="form-control" rows="20" style="font-family: Menlo,Monaco,Consolas,monospace;" readonly>{{ yaml }}</textarea>
        <br>
      
      </div>




      <div role="tabpanel" class="tab-pane" id="settings">
        <div class="row">
            <div class="col-md-6">
               <h3>Settings</h3>
               <form>
                   <button type="button" class="btn btn-danger" id="delete-collection">Delete collection</button>
               </form>
            </div>
            <div class="col-md-6">
               <h3>About</h3>
               <p>Arst</p>
            </div>
        </div>
      </div>
   </div>
</div>{% endblock %}
