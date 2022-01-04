const rangeArr = (start, enwd) =>  [...Array(end - start).keys()].map(i => i + start)
const zip = (a, ...b) => a.map((el, idx) => [el, ...b.map(arr => arr[idx])])
