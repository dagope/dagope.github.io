---
layout: page
title: Comunidad
published: false
---

<p class="message">
Aquí podrás encontrar un historial de las publicaciones, charlas, videos y contribuciones a la comunidad técnica:
</p>

<div id="contributions">
<table>
{% for item in site.data.contributions %}
  <tr>
    <td>{{item.date}}</td>
    <td>{{item.role}}</td>
    <td>{{item.name}}</td>
    <td>{{item.description}}</td>
  </tr>
{% endfor %}
<table>
</div>


<div id="archive">
{% for post in site.posts %}
  {% assign currentdate = post.date | date: "%Y" %}
  {% if currentdate != date %}
    {% unless forloop.first %}</ul>{% endunless %}
    <h1 id="y{{post.date | date: "%Y"}}">{{ currentdate }}</h1>
    <ul>
    {% assign date = currentdate %}
  {% endif %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% if forloop.last %}</ul>{% endif %}
{% endfor %}
</div>