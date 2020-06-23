var expect  = require('chai').expect;
var request = require('request');

it('Main page content', function(done) {
    request('http://localhost:8000' , function(error, response, body) {
        expect(body).to.equal('i am Nodejs-branch1');
        done();
    });
});

it('Main page status', function(done) {
    request('http://localhost:8000' , function(error, response, body) {
        expect(response.statusCode).to.equal(200);
        done();
    });
});

it('About page content', function(done) {
    request('http://localhost:8000/about' , function(error, response, body) {
        expect(response.statusCode).to.equal(404);
        done();
    });
});
