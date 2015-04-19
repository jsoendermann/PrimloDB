{% extends "layout.html" %}

{% block content %}
<div class="row">
   <div class="col-md-6">
      <h3>Collections</h3>
      <ul id="collections-list">
         {% for collection_info in collections_info %}
            <li class="collection-link" value="{{collection_info.name}}">{{collection_info.name}}</li>
         {% endfor %}
      </ul>
      <form class="form" action="/collections/" method="post">
         <div id="name-form" class="input-group" style="width:100%">
            <input type="text" class="form-control" name="new-collection-name" id="new-collection-name" placeholder="New collection name...">
            <span class="input-group-btn">
            <button class="btn btn-primary" type="submit">Create</button>
            </span> 
         </div>
         <p id="name-error" class="help-block hidden">Error.</p>
      </form>
   </div>
   <div class="col-md-6">
      <h3>About</h3>
      <p>Welcome to PrimloDB, a <a href="http://en.wikipedia.org/wiki/YAML">YAML</a>-based personal database. You can create a new collection on the left.</p>
      <p>PrimloDBs source code is hosted <a href="https://github.com/jsoendermann/PrimloDB">here</a>. Please send me a pull request on GitHub if you fix a bug or add a cool feature.</p>
   </div>
</div>
{% endblock %}
