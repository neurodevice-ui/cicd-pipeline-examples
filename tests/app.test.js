const request = require('supertest');
const { app, server } = require('../app/server');

describe('Express App', () => {
  afterAll(done => {
    server.close();
    done();
  });

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const res = await request(app)
        .get('/')
        .expect(200);
      
      expect(res.body.message).toBe('Welcome to CI/CD Pipeline Example!');
      expect(res.body.version).toBe('1.0.0');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const res = await request(app)
        .get('/health')
        .expect(200);
      
      expect(res.body.status).toBe('healthy');
      expect(res.body).toHaveProperty('uptime');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /api/users', () => {
    it('should return users array', async () => {
      const res = await request(app)
        .get('/api/users')
        .expect(200);
      
      expect(res.body.users).toBeInstanceOf(Array);
      expect(res.body.users).toHaveLength(2);
      expect(res.body.users[0]).toHaveProperty('id');
      expect(res.body.users[0]).toHaveProperty('name');
      expect(res.body.users[0]).toHaveProperty('email');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404', async () => {
      const res = await request(app)
        .get('/nonexistent')
        .expect(404);
      
      expect(res.body.error).toBe('Route not found');
      expect(res.body.path).toBe('/nonexistent');
    });
  });
});