import {zip, zip3, zip4, rangeArr} from './utils';


describe('zip', () => {
  it('should combine arrays with 1 element', () => {
    expect(zip([1], [2])).toStrictEqual([[1,2]]);
    expect(zip3([1], [2], [3])).toStrictEqual([[1,2,3]]);
    expect(zip4([1], [2], [3], [4])).toStrictEqual([[1,2,3,4]]);
  })
})

describe(rangeArr, () => {
  it('should create array with all element from start to end -1', () => {
    expect(rangeArr(1, 4)).toStrictEqual([1,2,3])
  })
})


