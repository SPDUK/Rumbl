import Player from './player';
const Video = {
  init(socket, element) {
    if (!element) return;

    const playerId = element.getAttribute('data-player-id');
    const videoId = element.getAttribute('data-id');

    socket.connect();

    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket);
    });
  },
  onReady(videoId, socket) {
    const msgContainer = document.getElementById('msg-container');
    const msgInput = document.getElementById('msg-input');
    const postButton = document.getElementById('msg-submit');
    let lastSeenId = 0;
    const vidChannel = socket.channel('videos:' + videoId, () => {
      last_seen_id: lastSeenId;
    });

    msgContainer.addEventListener('click', e => {
      e.preventDefault();
      let seconds =
        e.target.getAttribute('data-seek') || e.target.parentNode.getAttribute('data-seek');
      if (!seconds) {
        return;
      }
      Player.seekTo(seconds);
    });

    postButton.addEventListener('click', e => {
      const payload = { body: msgInput.value, at: Player.getCurrentTime() };
      // send the new_annotation payload to the server
      vidChannel.push('new_annotation', payload).receive('error', e => console.log(e));
      msgInput.value = '';
    });

    // when recieving a new annotation event back from the server
    vidChannel.on('new_annotation', resp => {
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    vidChannel
      .join()
      .receive('ok', resp => {
        let ids = resp.annotations.map(ann => ann.id);
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        }

        this.scheduleMessages(msgContainer, resp.annotations);
      })
      .receive('error', reason => console.log('join failed', reason));
  },
  renderAnnotation(msgContainer, { user, body, at }) {
    const template = document.createElement('div');
    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `;
    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },
  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduleTimer);
    this.schedulerTimer = setTimeout(() => {
      const ctime = Player.getCurrentTime();
      const remaining = this.renderAtTime(annotations, ctime, msgContainer);
      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  },
  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(ann => {
      if (ann.at > seconds) {
        return true;
      } else {
        this.renderAnnotation(msgContainer, ann);
        return false;
      }
    });
  },
  formatTime(at) {
    const date = new Date(null);
    date.setSeconds(at / 1000);
    return date.toISOString().substr(14, 5);
  },
  esc(str) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }
};
export default Video;
