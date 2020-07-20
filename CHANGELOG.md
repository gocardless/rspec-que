## 2.0.1 (July 20, 2020)

* Fix matches to support `anything` matcher

## 2.0.0 (May 24, 2017)

* Support matching on the number of jobs enqueued

### Breaking change
* Expectations that don't define an explicit number of jobs will default to **exactly once**. Previous behaviour was to expect at-least-once.

## 1.1.0 (May 3, 2017)

* Support matching jobs based on their priority
