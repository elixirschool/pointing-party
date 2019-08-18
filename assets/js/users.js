import { forEach, isNil, map, none } from 'ramda'

const updateUsers = presence => {
  const usersElem = document.querySelector('.users')
  usersElem.innerHTML = ''

  const users = presence.list(userData)
  forEach(addUser(usersElem))(users)

  if (allHaveEstimated(users)) {
    forEach(showPoints(usersElem))(users)
  }
}

const userData = (userId, { metas: [{ points }, ..._rest]}) => ({ userId, points })

const showPoints = usersElem => ({userId, points}) => {
  const userElem = document.querySelector(`.${userId}.user-estimate`)
  userElem.innerHTML = points
}

const addUser = usersElem => ({userId, points}) => {
  const userElem = document.createElement('dt')
  userElem.appendChild(document.createTextNode(userId))
  userElem.setAttribute('class', 'col-8')

  const estimateElem = document.createElement('dd')
  estimateElem.setAttribute('class', `${userId} user-estimate col-4`)

  usersElem.appendChild(userElem)
  usersElem.appendChild(estimateElem)
}

const allHaveEstimated = users => {
  const pointsCollection = map(({ points }) => points)(users)

  return none(isNil)(pointsCollection)
}

export default updateUsers
