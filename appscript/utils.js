const rangeArr = (start, end) =>  [...Array(end - start).keys()].map(i => i + start)
const zip = (a, ...b) => a.map((el, idx) => [el, ...b.map(arr => arr[idx])])
