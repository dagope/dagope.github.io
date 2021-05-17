---
layout: page
title: Contribuciones
---

<p>
Aquí podrás encontrar un historial de las publicaciones, charlas, videos y contribuciones a la comunidad técnica:
</p>

{% assign months = "Enero|Febrero|Marzo|Abril|Mayo|Junio|Julio|Agosto|Septiembre|Octubre|Noviembre|Diciembre" | split: "|" %}


<div id="contributions" class="datagrid">
  <table>
    {% for item in site.data.contributions %}
    {% assign m = item.date | date: "%-m" | minus: 1 %}
    {% assign month = months[m] %}
    {% assign year = item.date | date: "%Y" %}
    <tr>
      <td style="width:75px;"><span title="{{item.date}}">{{ year }}, {{month}}</span></td>
      <td>
        <!-- speaker | organizer | writer | contributor -->
        {% if item.role == "speaker" %} 
        <img loading="lazy" class="icon" src="{{ site.baseurl }}public/img/icons/headphones2.svg" title="speaker" alt="speaker"/>
        {% endif %}
        {% if item.role == "organizer" %} 
        <img loading="lazy" class="icon" src="{{ site.baseurl }}public/img/icons/hierarchical-structure.svg" title="organizer" alt="organizer"/>
        {% endif %}
        {% if item.role == "writer" %} 
        <img loading="lazy" class="icon" src="{{ site.baseurl }}public/img/icons/note.svg" title="writer" alt="writer"/>
        {% endif %}
        {% if item.role == "contributor" %} 
        <img loading="lazy" class="icon" src="{{ site.baseurl }}public/img/icons/startup.svg" title="contributor" alt="contributor"/>
        {% endif %}
      </td>
      <td>
        <span class="titleContribution">{{item.name}}</span>
        <br/>{{item.description}}
        <br/>
        <div class="listIcons">
        {% if item.web != blank %} 
          <a href="{{item.web}}" target="_blank" title="Web de referencia"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/world-wide-web.svg" alt="icono lugar"/></a>
        {% endif %}
        {% if item.meetup != blank %} 
          <a href="{{item.meetup}}" target="_blank" title="Evento meetup"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/meetup.svg" alt="icono meetup"/></a>
        {% endif %} 
        {% if item.video != blank %} 
          <a href="{{item.video}}" target="_blank" title="Video"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/youtube.svg" alt="icono video"/></a>
        {% endif %}
        {% if item.slides != blank %} 
          <a href="{{item.slides}}" target="_blank" title="Prestenación"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/slideshow.svg" alt="icono slides"/></a>
        {% endif %} 
        {% if item.github_repo != blank %} 
          <a href="{{item.github_repo}}" target="_blank" title="Repositorio de código"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/github.svg" alt="icono github"/></a>
        {% endif %} 
        {% if item.tweet != blank %} 
          <a href="{{item.tweet}}" target="_blank" title="Mención en twitter"><img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/twitter.svg" alt="icono tweet"/></a>
        {% endif %} 
        </div>
        <div class="containerPlace">
        {% if item.place != blank %}
          <img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/place.svg" title="{{item.place}}" alt="icono lugar"/>
          {{item.place}}
        {% else %}
          {% if item.mode == "online" %}
            <img loading="lazy" class="iconInLine" src="{{ site.baseurl }}public/img/icons/streaming.svg" title="online" alt="icono streaming"/>
            Streaming
          {% endif %}
        {% endif %}
        </div>
      </td>
    </tr>
    {% endfor %}
  </table>
</div>

Aquí el principio de mi historia en la comunidad. Muchas charlas y eventos a los que asistí antes de animarme a subir a los escenarios. Desde mi etapa en Barcelona hasta el día de hoy pude conocer a grandes personas y muchos amigos que me he llevado. Nunca podré devolver a la comunidad todo lo que me ha dado.
Este historial continuará.

Happy community! 😎