import axios from 'axios'
import store from '../app';

const simpleAxios = axios.create({
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
});

const secureAxios = axios.create({
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
});

secureAxios.interceptors.request.use(config => {
  const method = config.method.toUpperCase()
  if (method !== 'OPTIONS' && method !== 'GET') {
    config.headers = {
      ...config.headers,
      'X-CSRF-TOKEN': store.store.state.csrf,
      'Authorization': "Bearer " + `${store.store.state.token}`
    }
  } else if (method === 'GET'){
    config.headers = {
      ...config.headers,
      'Authorization': "Bearer " + `${store.store.state.token}`
    }
  }
  return config
})

secureAxios.interceptors.response.use(null, error => {
  if (error.response && error.response.config && error.response.status === 403) {
    return simpleAxios.post('/api/v1/refresh', {}, { headers: { 'X-CSRF-TOKEN': store.store.state.csrf, 'Authorization': "Bearer " + `${store.store.state.token}` }})
    .then(response => {
      simpleAxios.get('/api/v1/users/me', {params: { position: 'login' }}, { headers: { 'Authorization': "Bearer " + `${response.data.access_token}`} })
       .then(meResponse => store.store.commit('setCurrentUser', { currentUser: meResponse.data, csrf: response.data.csrf, token: response.data.access_token}))
       console.log(meResponse)
       let retryConfig = error.response.config
       console.log(retryConfig)
       retryConfig.headers['X-CSRF-TOKEN'] = response.data.csrf
       retryConfig.headers['Authorization'] = "Bearer " + `${response.data.access_token}`
       return simpleAxios.request(retryConfig)
    }).catch(error => {
      // store.store.commit('unsetCurrentUser')
      return Promise.reject(error)
    })
  } else {
    return Promise.reject(error)
  }
})

export {
  simpleAxios,
  secureAxios
}