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
      <p>
         Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras lacus tortor, pulvinar et convallis dictum, pulvinar vitae sapien. Proin consectetur quis odio ac iaculis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla non sapien nec nisi pharetra ornare vitae eu tortor. Cras in rhoncus nulla. Fusce pharetra, lectus et accumsan tristique, arcu neque congue lacus, sit amet pellentesque ligula odio id massa. Maecenas sit amet enim sit amet mauris facilisis tristique ultricies sed lorem. Etiam justo magna, aliquam vitae eros rhoncus, viverra condimentum tortor. Cras vehicula sed lacus vitae lacinia.
      </p>
      <p>
         Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed et accumsan sem, ac dignissim ipsum. Fusce hendrerit massa ac diam mollis, vitae ullamcorper quam bibendum. Vestibulum eget nisi quis libero porta lacinia in non nunc. Curabitur pretium finibus velit non tincidunt. Nullam volutpat augue in condimentum interdum. Ut in euismod nulla. Suspendisse vitae arcu magna. Aenean a ipsum eu mauris pellentesque convallis eu ut ipsum. Donec euismod sit amet sapien vel elementum. Donec quis consequat libero.
      </p>
   </div>
</div>
{% endblock %}
